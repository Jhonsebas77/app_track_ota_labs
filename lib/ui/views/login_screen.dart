part of com.app_track_ota_labs.app.views;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String route = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();
  bool _obscureText = true;
  bool _isLoading = false;
  String? _errorMsg;
  String _appName = '...';
  String _version = '...';
  String _buildNumber = '...';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    PackageInfo info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _appName = info.appName;
      _version = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  TextStyle _label({
    Color color = BlueprintColors.textMuted,
    double size = 10,
    double spacing = 1.5,
    FontWeight weight = FontWeight.w500,
  }) => TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    color: color,
    fontSize: size,
    letterSpacing: spacing,
    fontWeight: weight,
    height: 1.2,
  );

  /// Inicia sesión con [hardcodedEmail] (`AUTH_EMAIL` del DartDefine) y la
  /// contraseña escrita en pantalla.
  Future<void> _login() async {
    if (_isLoading) return;
    // Se lee el provider antes del primer `await` para no usar `context`
    // después de un gap async.
    AppProvider appProvider = prov.Provider.of<AppProvider>(
      context,
      listen: false,
    );

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    await HapticFeedback.mediumImpact();

    String? error;
    try {
      await appProvider.login(hardcodedEmail, _passwordController.text);
    } on AuthException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'ERR: UNEXPECTED_FAILURE';
    }

    if (!mounted) return;
    if (error == null) {
      showSuccessSnackBar(context, 'Login successfully');
    } else {
      setState(() => _errorMsg = error);
      showErrorSnackBar(context, 'Usuario o contraseña erróneo');
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: BlueprintColors.background,
    body: GridBackground(
      child: Stack(
        children: <Widget>[
          const ScanlineOverlay(),
          const Positioned.fill(
            child: IgnorePointer(child: CornerBrackets(size: 28, inset: 24)),
          ),
          SafeArea(
            child: Column(
              children: <Widget>[
                _buildHeader(),
                Expanded(child: _buildBody()),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildHeader() =>
      Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: BlueprintColors.accentOrange,
                        width: 2,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'SYSTEM_STATUS',
                        style: _label(size: 9, spacing: 1.5),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: <Widget>[
                          _PulseDot(),
                          const SizedBox(width: 6),
                          Text(
                            'OPERATIONAL',
                            style: _label(
                              color: BlueprintColors.successGreen,
                              size: 10,
                              spacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      'Ref_ID: MED_01',
                      style: _label(size: 9, spacing: 0.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'COORD: 6.2442° N',
                      style: _label(size: 9, spacing: 0.5),
                    ),
                  ],
                ),
              ],
            ),
          )
          .animate()
          .fadeIn(duration: 600.ms, delay: 100.ms)
          .slideY(begin: -0.3, end: 0, duration: 600.ms, curve: Curves.easeOut);

  Widget _buildBody() => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Column(
      children: <Widget>[
        const SizedBox(height: 16),
        _buildLogoCluster()
            .animate()
            .fadeIn(duration: 700.ms, delay: 200.ms)
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1, 1),
              duration: 700.ms,
              curve: Curves.easeOut,
            ),
        const SizedBox(height: 24),
        _buildTitle().animate().fadeIn(duration: 500.ms, delay: 400.ms),
        const SizedBox(height: 40),
        ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Breakpoints.formMaxWidth,
              ),
              child: _buildForm(),
            )
            .animate()
            .fadeIn(duration: 500.ms, delay: 550.ms)
            .slideY(
              begin: 0.2,
              end: 0,
              duration: 500.ms,
              curve: Curves.easeOut,
            ),
        const SizedBox(height: 24),
      ],
    ),
  );

  Widget _buildLogoCluster() => SchematicRing(
    size: 128,
    child: Container(
      width: 128,
      height: 128,
      decoration: BoxDecoration(
        color: BlueprintColors.background,
        border: Border.all(
          color: BlueprintColors.outline.withAlpha(60),
          width: 1,
        ),
      ),
      child: ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.modulate),
        child: Image.asset('assets/logo_ota.png', fit: BoxFit.contain),
      ),
    ),
  );

  Widget _buildTitle() => Column(
    children: <Widget>[
      const Text(
        'APP_TRACK',
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          color: BlueprintColors.accentOrange,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          height: 1.1,
        ),
      ),
      const SizedBox(height: 6),
      Text('v$_version($_buildNumber)', style: _label(size: 9, spacing: 1)),
    ],
  );

  Widget _buildForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Row(
        children: <Widget>[
          const Icon(
            Icons.lock_outline,
            color: BlueprintColors.textMuted,
            size: 14,
          ),
          const SizedBox(width: 8),
          Text('AUTHENTICATION_PROTOCOL', style: _label(size: 10, spacing: 2)),
          const Spacer(),
          Text('ENCRYPTED_AES_256', style: _label(size: 8, spacing: 0.5)),
        ],
      ),
      const SizedBox(height: 16),
      _buildUserDisplay(),
      const SizedBox(height: 16),
      Text('SECURE_CREDENTIAL', style: _label(size: 9, spacing: 1.5)),
      const SizedBox(height: 8),
      _buildPasswordInput(),
      if (_errorMsg != null) ...<Widget>[
        const SizedBox(height: 8),
        Text(
          _errorMsg!,
          style: _label(color: BlueprintColors.danger, size: 9, spacing: 0.5),
        ),
      ],
      const SizedBox(height: 20),
      _buildActionButton(),
      const SizedBox(height: 16),
    ],
  );

  Widget _buildUserDisplay() => Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: BlueprintColors.outline.withAlpha(40),
        width: 1,
      ),
      color: BlueprintColors.surfaceContainerLow,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    child: Row(
      children: <Widget>[
        const Icon(
          Icons.person_outline,
          color: BlueprintColors.accentOrange,
          size: 16,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('SYSTEM_USER', style: _label(size: 8, spacing: 1.5)),
            const SizedBox(height: 2),
            Text(hardcodedEmail.split('@').first, style: _label()),
          ],
        ),
      ],
    ),
  );

  Widget _buildPasswordInput() => Stack(
    clipBehavior: Clip.none,
    children: <Widget>[
      TextField(
        controller: _passwordController,
        focusNode: _passwordFocus,
        obscureText: _obscureText,
        style: const TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          color: BlueprintColors.textPrimary,
          fontSize: 13,
          letterSpacing: 4,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'INPUT_PASSWORD',
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 12, right: 8),
            child: Icon(
              Icons.terminal,
              color: BlueprintColors.accentOrange,
              size: 18,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 44),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 16,
              color: BlueprintColors.textMuted,
            ),
            onPressed: () => setState(() => _obscureText = !_obscureText),
          ),
        ),
        onChanged: (_) {
          if (_errorMsg != null) setState(() => _errorMsg = null);
        },
        onSubmitted: (_) => _login(),
        textInputAction: TextInputAction.go,
      ),
      Positioned(
        right: -12,
        top: 0,
        child: Column(
          children: <Widget>[
            Container(
              width: 1,
              height: 24,
              color: BlueprintColors.outline.withAlpha(80),
            ),
            Container(
              width: 10,
              height: 1,
              color: BlueprintColors.outline.withAlpha(80),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildActionButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _isLoading ? null : _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: BlueprintColors.accentOrange,
        foregroundColor: BlueprintColors.onAccent,
        disabledBackgroundColor: BlueprintColors.accentOrange.withAlpha(120),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        side: const BorderSide(color: BlueprintColors.accentOrange, width: 1),
      ),
      child: _isLoading
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: BlueprintColors.onAccent,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'AUTHENTICATING...',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                    color: BlueprintColors.onAccent,
                  ),
                ),
              ],
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'AUTHENTICATE',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                    color: BlueprintColors.onAccent,
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.bolt, size: 16, color: BlueprintColors.onAccent),
              ],
            ),
    ),
  );

  Widget _buildFooter() =>
      Container(
            decoration: const BoxDecoration(
              color: BlueprintColors.surfaceContainerLow,
              border: Border(
                top: BorderSide(
                  color: BlueprintColors.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'LEGAL_PROTOCOL',
                            style: _label(
                              color: BlueprintColors.accentOrange,
                              size: 9,
                              spacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '''©2026 OTA_LABS. ALL RIGHTS RESERVED.\n${_appName.toUpperCase()}.''',
                            style: _label(size: 8, spacing: 0.3),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const DiagnosticStrip(),
              ],
            ),
          )
          .animate()
          .fadeIn(duration: 500.ms, delay: 700.ms)
          .slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOut);
}

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 1).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: FadeTransition(
      opacity: _opacity,
      child: const SizedBox(
        width: 6,
        height: 6,
        child: ColoredBox(color: BlueprintColors.successGreen),
      ),
    ),
  );
}
