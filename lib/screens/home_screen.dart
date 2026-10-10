import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'all_products_screen.dart';
import 'cart_screen.dart';
import '../widgets/flashy_loader.dart';
import '../models/get_all_categories_model.dart';
import '../models/get_sub_category_by_id_model.dart';
import '../models/get_all_products_model.dart';
import '../models/get_products_sub_category_id_model.dart';
import '../controllers/categories_controller.dart';
import '../controllers/products_controller.dart';
import '../controllers/cart_controller.dart';
import '../config/api_config.dart';
import 'product_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();

  final CategoriesController _categoriesController = CategoriesController();
  List<Datum> categories = [];

  String? selectedCategoryId;
  bool isSubCategoriesLoading = false;
  List<SubCategoryData> subCategories = [];

  String? selectedSubCategoryId;
  bool isSubCategoryProductsLoading = false;
  List<SubCategoryProductData> subCategoryProducts = [];

  final ProductsController _productsController = ProductsController();
  final CartController _cartController = CartController();
  List<ProductData> products = [];
  int cartCount = 0;
  String baseUrl = "https://nidrip.mraalionline.com/api";
  bool isInitialLoading = true;

  // Local cart storage
  Map<String, int> localCart = {}; // product_id -> quantity
  Map<String, bool> isAddingToCart = {}; // product_id -> loading state
  Map<String, int> selectedQuantities =
      {}; // product_id -> quantity selected before adding

  // Carousel
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  // Trust badges scroll
  final ScrollController _trustBadgeController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadInitialData();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _trustBadgeController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  loadInitialData() async {
    await Future.wait([fetchCategories(), fetchProducts(), fetchCartCount()]);
    if (mounted) {
      setState(() {
        isInitialLoading = false;
      });
    }
  }

  // ================= FETCH CATEGORIES =================
  Future<void> fetchCategories() async {
    try {
      final fetchedCategories =
          await _categoriesController.fetchAllCategories();
      if (mounted) {
        setState(() {
          categories = fetchedCategories;
        });
      }
    } catch (e) {
      debugPrint('fetchCategories error: $e');
    }
  }

  // ================= FETCH SUB-CATEGORIES =================
  Future<void> fetchSubCategories(String categoryId) async {
    setState(() {
      selectedCategoryId = categoryId;
      isSubCategoriesLoading = true;
      subCategories = []; // clear previous
    });

    try {
      final fetchedSubCategories = await _categoriesController
          .fetchSubCategories(categoryId);
      if (mounted) {
        setState(() {
          subCategories = fetchedSubCategories;
          isSubCategoriesLoading = false;
        });
      }
    } catch (e) {
      debugPrint('fetchSubCategories error: $e');
      if (mounted) {
        setState(() {
          isSubCategoriesLoading = false;
        });
      }
    }
  }

  // ================= FETCH SUBCATEGORY PRODUCTS =================
  Future<void> fetchSubCategoryProducts(String subCategoryId) async {
    setState(() {
      selectedSubCategoryId = subCategoryId;
      isSubCategoryProductsLoading = true;
      subCategoryProducts = [];
    });

    try {
      final fetchedProducts = await _productsController
          .fetchProductsBySubCategory(subCategoryId);
      if (mounted) {
        setState(() {
          subCategoryProducts = fetchedProducts;
          isSubCategoryProductsLoading = false;
        });
      }
    } catch (e) {
      debugPrint('fetchSubCategoryProducts error: $e');
      if (mounted) {
        setState(() {
          isSubCategoryProductsLoading = false;
        });
      }
    }
  }

  // ================= FETCH PRODUCTS =================
  Future<void> fetchProducts() async {
    try {
      final fetchedProducts = await _productsController.fetchProducts();
      if (mounted) {
        setState(() {
          products = fetchedProducts;
        });
      }
    } catch (e) {
      debugPrint('fetchProducts error: $e');
    }
  }

  // ================= ADD TO CART =================
  Future<void> addToCart(String productId, int quantity) async {
    setState(() {
      isAddingToCart[productId] = true;
    });

    try {
      bool success = await _cartController.addToCart(productId, quantity);

      if (success) {
        setState(() {
          int currentQty = localCart[productId] ?? 0;
          int newQty = currentQty + quantity;
          if (newQty <= 0) {
            localCart.remove(productId);
          } else {
            localCart[productId] = newQty;
          }
          // Reset the quantity selector back to 1 after a successful add
          selectedQuantities[productId] = 1;
        });
        fetchCartCount();
        _showSnackBar("Product added to cart successfully! 🛒");
      } else {
        _showSnackBar("Failed to add product to cart", isError: true);
      }
    } catch (e) {
      _showSnackBar("Error: $e", isError: true);
    } finally {
      if (mounted) {
        setState(() {
          isAddingToCart[productId] = false;
        });
      }
    }
  }

  // ================= SNACKBAR =================
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor:
            isError ? const Color(0xFFE53935) : const Color(0xFF43A047),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 6,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ================= CART COUNT =================
  Future<void> fetchCartCount() async {
    try {
      var res = await http.get(Uri.parse("$baseUrl/cart_count"));
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        setState(() {
          cartCount = data["count"] ?? 0;
        });
      }
    } catch (e) {
      // optional: handle error
      setState(() {
        cartCount = 0;
      });
    }
  }

  // ================= PULL TO REFRESH =================
  Future<void> _onRefresh() async {
    await Future.wait([fetchCategories(), fetchProducts(), fetchCartCount()]);
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFFD215C); // Extracted brand color
    final Color bgColor = const Color(
      0xFFF8F9FA,
    ); // Off-white for slight contrast

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: Colors.white.withOpacity(0.95),
                elevation: 0,
                pinned: true,
                floating: true,
                titleSpacing: 16,
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                title: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      },
                      child: Image.asset(
                        "assets/favicon.png",
                        width: 40,
                        height: 40,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "NI Drip Central",
                          style: GoogleFonts.inter(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "Delivering to Belfast ",
                              style: GoogleFonts.inter(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                            Icon(
                              Icons.location_pin,
                              color: primaryColor,
                              size: 14,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CartScreen(),
                            ),
                          ).then((_) {
                            if (mounted) loadInitialData();
                          });
                        },
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          size: 26,
                          color: Colors.black87,
                        ),
                      ),
                      if (cartCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.4),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Text(
                              cartCount.toString(),
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60.0),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: searchController,
                        style: GoogleFonts.inter(color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: "Search items, categories...",
                          hintStyle: GoogleFonts.inter(
                            color: Colors.grey.shade500,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey.shade600,
                          ),
                          suffixIcon: Icon(
                            Icons.mic_none_outlined,
                            color: Colors.grey.shade500,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: RefreshIndicator(
            color: primaryColor,
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // ================= Hero Banner Carousel =================
                  isInitialLoading
                      ? Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: 180,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      )
                      : SizedBox(
                        height: 180,
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          children: [
                            _buildHeroCard(
                              "Next-Gen Audio",
                              "Experience pure sound.",
                              "assets/banner-1.png",
                            ),
                            _buildHeroCard(
                              "Smart Living",
                              "Upgrade your home today.",
                              "assets/banner-1.png",
                            ),
                            _buildHeroCard(
                              "Pro Computing",
                              "Power meets elegance.",
                              "assets/banner-1.png",
                            ),
                          ],
                        ),
                      ),
                  const SizedBox(height: 12),

                  // Dot indicators
                  if (!isInitialLoading)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                _currentPage == index
                                    ? primaryColor
                                    : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                  const SizedBox(height: 24),

                  // ================= eBay Rating Strip =================
                  SizedBox(
                    height: 40,
                    child: ListView(
                      controller: _trustBadgeController,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildTrustBadge("⭐ 5.0 eBay"),
                        _buildTrustBadge("✅ Verified Seller"),
                        _buildTrustBadge("🚚 Fast Delivery"),
                        _buildTrustBadge("🔒 Secure Payment"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 34),

                  // ================= Categories Section =================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Shop by Categories",
                          style: GoogleFonts.inter(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "See All",
                          style: GoogleFonts.inter(
                            color: primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  isInitialLoading
                      ? SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                width: 75,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: 50,
                                      height: 10,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                      : categories.isEmpty
                      ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            "No categories available",
                            style: GoogleFonts.inter(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                      : SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          physics: const BouncingScrollPhysics(),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            var cat = categories[index];
                            String cName = cat.name ?? "Unknown";
                            String cImage = cat.image ?? "";

                            String origin = ApiConfig.baseUrl.trim();
                            while (origin.endsWith('/')) {
                              origin = origin.substring(0, origin.length - 1);
                            }

                            String catImageUrl =
                                cImage.startsWith("http")
                                    ? cImage
                                    : (cImage.startsWith("/")
                                        ? "$origin$cImage"
                                        : "$origin/$cImage");

                            bool isSelected = selectedCategoryId == cat.id;

                            return GestureDetector(
                              onTap: () {
                                if (cat.id != null &&
                                    cat.id != selectedCategoryId) {
                                  fetchSubCategories(cat.id!);
                                } else if (cat.id == selectedCategoryId) {
                                  setState(() {
                                    selectedCategoryId = null;
                                    subCategories = [];
                                  });
                                }
                              },
                              child: Container(
                                width: 75,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            isSelected
                                                ? primaryColor.withOpacity(0.1)
                                                : Colors.white,
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? primaryColor
                                                  : Colors.grey.shade200,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: Image.network(
                                          Uri.encodeFull(catImageUrl),
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (c, e, s) => Icon(
                                                Icons.category,
                                                color:
                                                    isSelected
                                                        ? primaryColor
                                                        : Colors.grey.shade400,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      cName,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        color:
                                            isSelected
                                                ? primaryColor
                                                : Colors.black87,
                                        fontSize: 12,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                  // ================= Sub-Categories Section =================
                  if (selectedCategoryId != null) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Subcategories",
                        style: GoogleFonts.inter(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    isSubCategoriesLoading
                        ? SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            itemCount: 4,
                            itemBuilder: (context, index) {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  width: 75,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: 50,
                                        height: 10,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                        : subCategories.isEmpty
                        ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Text(
                              "No subcategories found",
                              style: GoogleFonts.inter(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        )
                        : SizedBox(
                          height: 110,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            physics: const BouncingScrollPhysics(),
                            itemCount: subCategories.length,
                            itemBuilder: (context, index) {
                              var subCat = subCategories[index];
                              String scName = subCat.name ?? "Unknown";
                              String scImage = subCat.image ?? "";

                              String origin = ApiConfig.baseUrl.trim();
                              while (origin.endsWith('/')) {
                                origin = origin.substring(0, origin.length - 1);
                              }

                              String subCatImageUrl =
                                  scImage.startsWith("http")
                                      ? scImage
                                      : (scImage.startsWith("/")
                                          ? "$origin$scImage"
                                          : "$origin/$scImage");

                              bool isSelected =
                                  selectedSubCategoryId == subCat.id;
                              return GestureDetector(
                                onTap: () {
                                  if (subCat.id != null &&
                                      subCat.id != selectedSubCategoryId) {
                                    fetchSubCategoryProducts(subCat.id!);
                                  }
                                },
                                child: Container(
                                  width: 80,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 65,
                                        height: 65,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color:
                                              isSelected
                                                  ? primaryColor.withOpacity(
                                                    0.1,
                                                  )
                                                  : Colors.white,
                                          border: Border.all(
                                            color:
                                                isSelected
                                                    ? primaryColor
                                                    : Colors.transparent,
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.network(
                                            Uri.encodeFull(subCatImageUrl),
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (c, e, s) => Icon(
                                                  Icons.category_outlined,
                                                  color: Colors.grey.shade400,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        scName,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          color: Colors.black87,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                  ],

                  if (selectedSubCategoryId != null) ...[
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Subcategory Products",
                        style: GoogleFonts.inter(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child:
                          isSubCategoryProductsLoading
                              ? GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: 4,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.48,
                                      crossAxisSpacing: 14,
                                      mainAxisSpacing: 14,
                                    ),
                                itemBuilder: (context, index) {
                                  return Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  );
                                },
                              )
                              : subCategoryProducts.isEmpty
                              ? Center(
                                child: Text(
                                  "No products found",
                                  style: GoogleFonts.inter(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              )
                              : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: subCategoryProducts.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.48,
                                      crossAxisSpacing: 14,
                                      mainAxisSpacing: 14,
                                    ),
                                itemBuilder: (context, index) {
                                  var product = subCategoryProducts[index];
                                  String pImage = product.image ?? "";
                                  String origin = ApiConfig.baseUrl.trim();
                                  while (origin.endsWith('/')) {
                                    origin = origin.substring(
                                      0,
                                      origin.length - 1,
                                    );
                                  }
                                  String imageUrl =
                                      pImage.startsWith("http")
                                          ? pImage
                                          : (pImage.startsWith("/")
                                              ? "$origin$pImage"
                                              : "$origin/$pImage");
                                  String pName = product.name ?? "Unknown";
                                  String pCategory =
                                      product.subCategory ??
                                      product.category ??
                                      "";
                                  String pPrice =
                                      product.price?.toString() ?? "0";
                                  String pId = product.id ?? "";
                                  String pRating =
                                      product.rating?.toString() ?? "4.8";
                                  String currency = "£";

                                  return _buildProductCard(
                                    imageUrl,
                                    pName,
                                    pCategory,
                                    pRating,
                                    currency,
                                    pPrice,
                                    pId,
                                  );
                                },
                              ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // ================= Products Grid =================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Trending ",
                              style: GoogleFonts.inter(
                                color: Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Now",
                              style: GoogleFonts.inter(
                                color: primaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AllProductsScreen(),
                              ),
                            ).then((_) {
                              if (mounted) loadInitialData();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              "View All",
                              style: GoogleFonts.inter(
                                color: Colors.black87,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child:
                        isInitialLoading
                            ? GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 4,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.48,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                  ),
                              itemBuilder: (context, index) {
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                );
                              },
                            )
                            : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount:
                                  products.length > 4 ? 4 : products.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.48,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                  ),
                              itemBuilder: (context, index) {
                                var product = products[index];

                                String pImage = product.image ?? "";
                                String origin = ApiConfig.baseUrl.trim();
                                while (origin.endsWith('/')) {
                                  origin = origin.substring(
                                    0,
                                    origin.length - 1,
                                  );
                                }
                                String imageUrl =
                                    pImage.startsWith("http")
                                        ? pImage
                                        : (pImage.startsWith("/")
                                            ? "$origin$pImage"
                                            : "$origin/$pImage");

                                String pName = product.name ?? "Unknown";
                                String pCategory =
                                    product.subCategory ??
                                    product.category ??
                                    "";
                                String pPrice =
                                    product.price?.toString() ?? "0";
                                String pId = product.id ?? "";
                                String pRating =
                                    product.rating?.toString() ?? "4.8";
                                String currency = "£";

                                return _buildProductCard(
                                  imageUrl,
                                  pName,
                                  pCategory,
                                  pRating,
                                  currency,
                                  pPrice,
                                  pId,
                                );
                              },
                            ),
                  ),

                  const SizedBox(height: 30),

                  // ================= Delivery Banner =================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.red, Colors.pink],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Fast & Free Delivery",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              children: [
                                const TextSpan(
                                  text: "Free delivery on orders over 300",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(String title, String subtitle, String imagePath) {
    // Red brand gradient banner
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFFD215C), Color(0xFFFF577F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFD215C).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.2, // very subtle on light theme
              child: Image.asset(
                imagePath,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.phonelink,
                    color: Colors.white,
                    size: 100,
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFFD215C),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      "Shop Now",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Pill shape
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(
    String imageUrl,
    String pName,
    String pCategory,
    String pRating,
    String currency,
    String pPrice,
    String pId,
  ) {
    int selectedQty = selectedQuantities[pId] ?? 1;
    bool isLoading = isAddingToCart[pId] ?? false;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(productId: pId),
          ),
        ).then((_) {
          if (mounted) loadInitialData();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    Uri.encodeFull(imageUrl),
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (c, e, s) => Container(
                          height: 150,
                          color: Colors.grey.shade100,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey.shade400,
                            size: 40,
                          ),
                        ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      color: Colors.grey.shade600,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pCategory,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFB800),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pRating,
                          style: GoogleFonts.inter(
                            color: Colors.black54,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$currency$pPrice",
                          style: GoogleFonts.inter(
                            color: Colors.black87,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          height: 26,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (selectedQty > 1) {
                                    setState(
                                      () =>
                                          selectedQuantities[pId] =
                                              selectedQty - 1,
                                    );
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.0,
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    size: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              Text(
                                "$selectedQty",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(
                                    () =>
                                        selectedQuantities[pId] =
                                            selectedQty + 1,
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.0,
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 34,
                      child: ElevatedButton(
                        onPressed:
                            isLoading
                                ? null
                                : () {
                                  addToCart(pId, selectedQty);
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFD215C),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: Colors.white.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child:
                            isLoading
                                ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_shopping_cart,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Add",
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
