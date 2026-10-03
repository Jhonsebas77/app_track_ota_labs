part of com.app_track_ota_labs.app.widgets;

class DetailedCard extends StatelessWidget {
  const DetailedCard({required this.app, super.key, this.onTap});

  final AppModel app;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: BlueprintColors.surfaceContainerLow,
      border: kIndustrialBorder,
    ),
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.all(14),
      leading: AppIconBox(app: app),
      title: Text(
        app.name,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 4),
          Text(
            '${app.bundleId}  //  v${app.version}',
            style: AppTextStyles.bodySmall.copyWith(
              color: BlueprintColors.accentOrange,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: <Widget>[
              for (String platform in app.platform)
                CustomBadge(
                  label: platform.toUpperCase(),
                  color: BlueprintColors.infoBlue,
                ),
            ],
          ),
          if (app.description.isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              app.description,
              style: AppTextStyles.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
      trailing: AppStatusBadge(status: app.status),
    ),
  );
}
