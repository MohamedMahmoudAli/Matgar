// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures, avoid_function_literals_in_foreach_calls, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matgar/Screens/Categories/category.dart';
import 'package:matgar/Screens/Favorites/favorite.dart';
import 'package:matgar/Screens/Products_Home/product_Home.dart';
import 'package:matgar/Screens/setting/setting.dart';
import 'package:matgar/cubit/state.dart';
import 'package:matgar/model/cart/add_cart_model.dart';
import 'package:matgar/model/cart/get_cart_model.dart';
import 'package:matgar/model/cart/update_cart_model.dart';
import 'package:matgar/model/category/category_details_model.dart';
import 'package:matgar/model/category/category_model.dart';
import 'package:matgar/model/faq/faq_model.dart';
import 'package:matgar/model/favorite/favorite_model.dart';
import 'package:matgar/model/home/home_model.dart';
import 'package:matgar/model/login/login_model.dart';
import 'package:matgar/network/End_Points.dart';
import 'package:matgar/network/dio_helper.dart';
import 'package:matgar/shared/components/components.dart';
import 'package:matgar/shared/components/constants.dart';


class MainCubit extends Cubit<MainStates> {
  MainCubit() : super(MainInitialStates());
  static MainCubit get(context) => BlocProvider.of(context);

  Map<dynamic, dynamic> favorites = {};
  Map<dynamic, dynamic> cart = {};

  int currentIndex = 0;

  List<Widget> pages = [
    ProductsScreen(),
    CategoriesScreen(),
    FavoritesScreen(),
    SettingScreen(),
  ];

  void ChangeNavBar(int index) {
    currentIndex = index;
    emit(ChangeNavBarItem());
  }
/////////get user data
  LoginModel? UserData;
  void getUserData() {
    emit(UserLoginLoadingStates());

    DioHelper.getData(
      url: PROFILE,
      token: token,
    ).then((value) {
      UserData = LoginModel.fromJson(value.data);
      emit(UserLoginSuccessStates(UserData!));
    }).catchError((error) {
      print(error.toString());
      emit(UserLoginErrorStates(error.toString()));
    });
  }
  ////////finish
/////////update user data

  void UpdateUserData({
    required String email,
    required String name,
    required String phone,
    String? image,
  }) {
    emit(UserUpdateLoadingStates());

    DioHelper.putData(
      url: UPDATE,
      token: token,
      data: {
        'email': email,
        'name': name,
        'phone': phone,
      },
    ).then((value) {
      UserData = LoginModel.fromJson(value.data);
      emit(UserUpdateSuccessStates(UserData!));
    }).catchError((error) {
      print(error.toString());
      emit(UserUpdateErrorStates(error.toString()));
    });
  }
  ////////finish
/////////update home all data

  HomeModel? homeModel;

  void getHomeData() {
    emit(HomeLoadingStates());
    DioHelper.getData(
      url: HOME,
      token: token,
    ).then((value) {
      homeModel = HomeModel.fromJson(value.data);
      //printFullText(homeModel.data.banners.toString());
      print(homeModel!.status);
      print(token);
      homeModel!.data!.products.forEach((element) {
        favorites.addAll({
          element.id: element.inFavorites,
        });
      });
      homeModel!.data!.products.forEach((element) {
        cart.addAll({
          element.id: element.inCart,
        });
      });
      emit(HomeSuccessStates());
    }).catchError((error) {
      print(error.toString());
      emit(HomeErrorStates());
    });
  }
////////finish
/////////update categories data
  CategoriesModel? categoriesModel;
  void getCategoriesData() {
    DioHelper.getData(
      url: CATEGORIES,
      token: token,
    ).then((value) {
      categoriesModel = CategoriesModel.fromJson(value.data);

      emit(CategoriesSuccessStates());
    }).catchError((error) {
      print(error.toString());
      emit(CategoriesErrorStates());
    });
  }

  CategoryDetailModel? categoriesDetailModel;
  void getCategoriesDetailData(int categoryID) {
    emit(CategoryDetailsLoadingStates());
    DioHelper.getData(url: "categories/$categoryID", query: {
      'category_id': '$categoryID',
    }).then((value) {
      categoriesDetailModel = CategoryDetailModel.fromJson(value.data);
      categoriesDetailModel!.data!.productData!.forEach((element) {});
      print('categories Detail ${categoriesDetailModel!.status}');
      emit(CategoryDetailsSuccessStates());
    }).catchError((error) {
      emit(CategoryDetailsErrorStates());
      print(error.toString());
    });
  }

// changeCart
  ChangeCartModel? changeCartModel;
  void changeCart(int productId) {
    // cart[productId] = !cart[productId];
    emit(ChangeCartStates());
    DioHelper.postData(
      url: CARTS,
      data: {
        'product_id': productId,
      },
      token: token,
    ).then((value) {
      changeCartModel = ChangeCartModel.fromJson(value.data);
      // print('changeCartModel ' + changeCartModel.status.toString());
      if (changeCartModel!.status!) {
        getCartData();
        getHomeData();
      } else
        ShowToast(
          text: changeCartModel!.message!,
          state: ToastStates.SUCCESS,
        );
      emit(ChangeCartSuccessStates(changeCartModel!));
    }).catchError((error) {
      emit(ChangeCartErrorStates());
      print(error.toString());
    });
  }

  // get cart data
  CartModel? cartModel;

  void getCartData() {
    emit(CartLoadingStates());
    DioHelper.getData(url: CARTS, token: token).then((value) {
      cartModel = CartModel.fromJson(value.data);
      // print('Get Cart'+cartModel.toString());
      emit(GetCartSuccessStates());
    }).catchError((error) {
      print(error.toString());
      emit(GetCartErrorStates());
    });
  }

// update cart
  UpdateCartModel? updateCartModel;
  void updateCartData(int id, int quantity) {
    emit(UpdateCartLoadingStates());
    DioHelper.putData(
        url: 'carts/$id',
        data: {
          'quantity': '$quantity',
        },
        token: token)
        .then((value) {
      updateCartModel = UpdateCartModel.fromJson(value.data);
      if (updateCartModel!.status!) {
        getCartData();
      } else
        ShowToast(
          text: updateCartModel!.message!,
          state: ToastStates.SUCCESS,
        );
      //  print('updateCartModel ' + updateCartModel.status.toString());
      emit(UpdateCartSuccessStates());
    }).catchError((error) {
      emit(UpdateCartErrorStates());
      print(error.toString());
    });
  }

  ChangeFavoritesModel? changeFavoritesModel;

  void changeFavorites(int productID) {
    favorites[productID] = !favorites[productID];
    emit(ChangeFavoritesStates());

    DioHelper.postData(url: FAVORITES, token: token, data: {
      'product_id': productID,
    }).then((value) {
      changeFavoritesModel = ChangeFavoritesModel.fromJson(value.data);
      print(value.data);

      if (!changeFavoritesModel!.status!) {
        favorites[productID] = !favorites[productID];
      } else {
        getFavoritesData();
      }
      emit(ChangeFavoritesSuccessStates(changeFavoritesModel!));
    }).catchError((error) {
      favorites[productID] = !favorites[productID];
      emit(ChangeFavoritesErrorStates());
    });
  }

  FavoritesModel? favoritesModel;

  void getFavoritesData() {
    emit(FavoritesLoadingStates());
    DioHelper.getData(
      url: FAVORITES,
      token: token,
    ).then((value) {
      favoritesModel = FavoritesModel.fromJson(value.data);
      emit(GetFavoritesSuccessStates());
    }).catchError((error) {
      print(error.toString());
      emit(GetFavoritesErrorStates());
    });
  }

  ProductResponse? productResponse;
  Future getProductData(productId) async {
    productResponse ;
    emit(ProductLoadingStates());
    return await DioHelper.getData(url: 'products/$productId', token: token)
        .then((value) {
      productResponse = ProductResponse.fromJson(value.data);
      //print('Product Detail '+productsModel.status.toString());
      emit(ProductSuccessStates(productResponse!));
    }).catchError((error) {
      emit(ProductErrorStates());
      print(error.toString());
    });
  }

  FaqModel? faqModel;
  void getFaqData() {
    emit(FaqLoadingStates());
    DioHelper.getData(url: FAQS, token: token).then((value) {
      faqModel = FaqModel.fromJson(value.data);
      emit(GetFaqSuccessStates());
    }).catchError((error) {
      print(error.toString());
      emit(GetFaqErrorStates());
    });
  }

  IconData suffix = Icons.visibility_outlined;
  bool isPassword = true;
  void ShowPassword() {
    isPassword = !isPassword;
    suffix =
    isPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined;

    emit(ShowPasswordStates());
  }
}