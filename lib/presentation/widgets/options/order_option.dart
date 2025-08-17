import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/core/enums/order_by.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';

class OrderOption extends StatelessWidget {
  const OrderOption({super.key});

  FocusNode get _focusNode => FocusNode();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final primaryColor = state.settings.primaryColor;

        return SectionItem(
          icon: FontAwesomeIcons.lightArrowDownShortWide,
          title: context.tr('options.order_by'),
          onTap: _focusNode.requestFocus,
          trailing: DropdownButton<OrderBy>(
            value: OrderBy.titleAsc,
            icon: const Icon(Icons.arrow_drop_down),
            focusNode: _focusNode,
            elevation: 16,
            style: TextStyle(color: context.textPrimary, fontSize: 16),
            underline: Container(height: 2, color: primaryColor),
            onChanged: (OrderBy? value) {
              if (value != null) {
                // TODO(Armando): Implementar cambio de orden solo para la lista principal
              }
            },
            items: OrderBy.values.map<DropdownMenuItem<OrderBy>>((value) {
              return DropdownMenuItem<OrderBy>(
                value: value,
                child: Text(value.value),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
