import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lungs_pneumonia_ai/core/base/state/base_state.dart';
import 'package:lungs_pneumonia_ai/view/specialization/controller/specialization_controller.dart';

class SpecializationBadgeWidget extends StatelessWidget {
  final String specializationId;

  const SpecializationBadgeWidget({super.key, required this.specializationId});

  @override
  Widget build(BuildContext context) {
    final spec = SpecializationController.instance.specializations
        .firstWhereOrNull((s) => s.id == specializationId);
    if (spec == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Utility(context).dynamicWidthPixel(8),
        vertical: Utility(context).dynamicWidthPixel(3),
      ),
      decoration: BoxDecoration(
        color: spec.color.withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(Utility(context).dynamicWidthPixel(6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(spec.icon, color: spec.color, size: 12),
          SizedBox(width: Utility(context).dynamicWidthPixel(4)),
          Text(
            spec.nameKey.tr,
            style: TextStyle(
              fontSize: Utility(context).dynamicTextSize(10),
              color: spec.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
