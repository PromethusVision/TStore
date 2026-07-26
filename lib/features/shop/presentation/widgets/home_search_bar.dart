import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const Key('home-search-bar'),
      color: Colors.white,
      borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
      child: InkWell(
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
        onTap: onTap,
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(
            horizontal: CustomerHomeV1Tokens.space16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
            border: Border.all(color: CustomerHomeV1Tokens.border),
            boxShadow: CustomerHomeV1Tokens.softShadow,
          ),
          child: const Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: CustomerHomeV1Tokens.petrol,
                size: 22,
              ),
              SizedBox(width: CustomerHomeV1Tokens.space12),
              Expanded(
                child: Text(
                  'Ürün, kategori veya mağaza ara',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CustomerHomeV1Tokens.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: CustomerHomeV1Tokens.petrol,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
