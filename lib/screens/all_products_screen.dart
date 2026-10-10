import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'cart_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../models/get_all_products_model.dart';
import '../controllers/products_controller.dart';
import '../config/api_config.dart';
import 'product_details_screen.dart';
import '../controllers/cart_controller.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  List categories = [];

  final ProductsController _productsController = ProductsController();
  List<ProductData> products = [];

  String selectedCategoryId = "all"; // Default active
  String baseUrl = "https://nidrip.mraalionline.com/api";
  int cartCount = 0;
  bool isInitialLoading = true;
  bool isProductsLoading = false;

  final ScrollController _tabController = ScrollController();
  final Color primaryColor = const Color(0xFFFD215C); // Brand color

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  loadInitialData() async {
    await Future.wait([
      fetchCategories(),
      fetchProducts(categoryId: selectedCategoryId),
      fetchCartCount(),
    ]);
    if (mounted) {
      setState(() {
        isInitialLoading = false;
      });
    }
  }

  // ================= FETCH CATEGORIES =================
  Future<void> fetchCategories() async {
    try {
      var res = await http.get(Uri.parse("$baseUrl/categories"));
      var data = json.decode(res.body);
      if (mounted) {
        setState(() {
          categories = data is Map ? (data['data'] ?? []) : data;
        });
      }
    } catch (e, st) {
      debugPrint('fetchCategories: $e $st');
    }
  }

  // ================= FETCH PRODUCTS =================
  Future<void> fetchProducts({String categoryId = "all"}) async {
    try {
      final fetchedProducts = await _productsController.fetchProducts();
      if (mounted) {
        setState(() {
          products = fetchedProducts;
        });
      }
    } catch (e) {
      if (mounted) setState(() => products = []);
    }
  }

  // ================= CART COUNT =================
  Future<void> fetchCartCount() async {
    try {
      var res = await http.get(Uri.parse("$baseUrl/cart_count"));
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        if (mounted) setState(() => cartCount = data["count"] ?? 0);
      }
    } catch (e) {
      if (mounted) setState(() => cartCount = 0);
    }
  }

  final CartController _cartController = CartController();

  // ================= ADD TO CART =================
  addToCart(String productId) async {
    try {
      bool success = await _cartController.addToCart(productId, 1);
      if (success) {
        fetchCartCount();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Product added to cart successfully! 🛒",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF43A047),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to add to cart")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // ================= SCROLL TAB TO CENTER =================
  scrollToCategory(int index) {
    if (!_tabController.hasClients) return;
    double screenWidth = MediaQuery.of(context).size.width;
    double scrollPos = index * 100 - (screenWidth / 2) + 50;
    if (scrollPos < 0) scrollPos = 0;
    _tabController.animateTo(
      scrollPos,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // ================= PULL TO REFRESH =================
  Future<void> _onRefresh() async {
    await Future.wait([
      fetchCategories(),
      fetchProducts(categoryId: selectedCategoryId),
      fetchCartCount(),
    ]);
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 8,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
    );
  }

  Widget _buildShimmerTabs() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            width: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Off-white for slight contrast
      appBar: CustomAppBar(
        title: "All Products",
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
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
                  top: 10,
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
      ),
      body: Column(
        children: [
          // ================= Category Tabs =================
          SizedBox(
            height: 60, // Fixed height for chips scroll view
            child:
                isInitialLoading
                    ? _buildShimmerTabs()
                    : Scrollbar(
                      controller: _tabController,
                      child: ListView.builder(
                        controller: _tabController,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: categories.length + 1,
                        itemBuilder: (context, index) {
                          String tabName;
                          String tabId;
                          if (index == 0) {
                            tabName = "All";
                            tabId = "all";
                          } else {
                            var cat = categories[index - 1];
                            tabName =
                                cat["category_name"] ??
                                cat["name"] ??
                                "Unknown";
                            tabId =
                                (cat["category_id"] ?? cat["id"])?.toString() ??
                                "all";
                          }

                          bool isSelected = selectedCategoryId == tabId;

                          return GestureDetector(
                            onTap: () {
                              if (isSelected)
                                return; // Prevent unnecessary refetches
                              setState(() {
                                selectedCategoryId = tabId;
                                isProductsLoading = true;
                              });
                              fetchProducts(categoryId: tabId).then((_) {
                                if (mounted) {
                                  setState(() {
                                    isProductsLoading = false;
                                  });
                                }
                              });
                              scrollToCategory(index);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 10,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? primaryColor : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? primaryColor
                                          : Colors.grey.shade300,
                                ),
                                boxShadow:
                                    isSelected
                                        ? [
                                          BoxShadow(
                                            color: primaryColor.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                        : [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                              ),
                              child: Center(
                                child: Text(
                                  tabName,
                                  style: GoogleFonts.inter(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          ),

          const SizedBox(height: 10),

          // ================= Products Grid =================
          Expanded(
            child: RefreshIndicator(
              color: primaryColor,
              onRefresh: _onRefresh,
              child: (isInitialLoading || isProductsLoading)
                  ? _buildShimmerGrid()
                  : products.isEmpty
                  ? LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: constraints.maxHeight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No products found",
                              style: GoogleFonts.inter(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: products.length,
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
                          origin = origin.substring(0, origin.length - 1);
                        }
                        String imageUrl =
                            pImage.startsWith("http")
                                ? pImage
                                : (pImage.startsWith("/")
                                    ? "$origin$pImage"
                                    : "$origin/$pImage");

                        String pName = product.name ?? "Unknown";
                        String pCategory =
                            product.subCategory ?? product.category ?? "";
                        String pPrice = product.price?.toString() ?? "0";
                        String pId = product.id ?? "";
                        String pRating = product.rating?.toString() ?? "4.8";
                        String currency = "£";

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ProductDetailsScreen(productId: pId),
                              ),
                            );
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
                                // Top Image
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
                                                Icons
                                                    .image_not_supported_outlined,
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
                                // Product Details Bottom Half
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                        const Spacer(),
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
                                        Text(
                                          "$currency$pPrice",
                                          style: GoogleFonts.inter(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        SizedBox(
                                          width: double.infinity,
                                          height:
                                              34, // Matches slimmed home layout
                                          child: ElevatedButton(
                                            onPressed: () {
                                              addToCart(pId);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryColor,
                                              foregroundColor: Colors.white,
                                              elevation: 2,
                                              shadowColor: primaryColor
                                                  .withOpacity(0.4),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
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
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
