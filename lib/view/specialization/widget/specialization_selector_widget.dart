import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lungs_pneumonia_ai/core/base/state/base_state.dart';
import 'package:lungs_pneumonia_ai/core/init/theme/color/color_theme.dart';
import 'package:lungs_pneumonia_ai/core/models/specialization_model.dart';
import 'package:lungs_pneumonia_ai/view/specialization/controller/specialization_controller.dart';

class SpecializationSelectorWidget extends StatelessWidget {
  final SpecializationModel? selected;
  final ValueChanged<SpecializationModel> onSelected;

  const SpecializationSelectorWidget({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final specs = SpecializationController.instance.specializations;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'selectSpecialization'.tr,
          style: Utility(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: Utility(context).dynamicWidthPixel(12)),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.65,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: specs.length,
          itemBuilder: (_, index) {
            final spec = specs[index];
            return _SpecCard(
              spec: spec,
              isSelected: selected?.id == spec.id,
              onTap: spec.isAvailable ? () => onSelected(spec) : null,
            );
          },
        ),
      ],
    );
  }
}

class _SpecCard extends StatelessWidget {
  final SpecializationModel spec;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SpecCard({
    required this.spec,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = spec.isAvailable ? spec.color : AppColors().grey1;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(Utility(context).dynamicWidthPixel(12)),
        decoration: BoxDecoration(
          color: isSelected ? spec.color.withOpacity(0.1) : AppColors().white,
          borderRadius:
              BorderRadius.circular(Utility(context).dynamicWidthPixel(14)),
          border: Border.all(
            color: isSelected ? spec.color : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(spec.icon,
                    color: activeColor,
                    size: Utility(context).dynamicTextSize(22)),
                const Spacer(),
                if (!spec.isAvailable)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Utility(context).dynamicWidthPixel(5),
                      vertical: Utility(context).dynamicWidthPixel(2),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors().grey1.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(
                          Utility(context).dynamicWidthPixel(5)),
                    ),
                    child: Text(
                      'soon'.tr,
                      style: TextStyle(
                        fontSize: Utility(context).dynamicTextSize(9),
                        color: AppColors().grey1,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: Utility(context).dynamicWidthPixel(6)),
            Text(
              spec.nameKey.tr,
              style: Utility(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: activeColor,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              spec.descriptionKey.tr,
              style: Utility(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors().grey1),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
