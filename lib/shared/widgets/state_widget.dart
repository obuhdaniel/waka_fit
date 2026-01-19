import 'package:flutter/material.dart';

enum ViewState { idle, loading, success, error }

class StateData {
  final ViewState state;
  final String? message;
  final String? title;
  final String? actionText; // Optional action text for buttons
  final VoidCallback? onRetry;
  final VoidCallback? onSuccess;
  final VoidCallback? onDismiss; // Added dismiss callback

  const StateData({
    required this.state,
    this.message,
    this.title,
    this.actionText,
    this.onRetry,
    this.onSuccess,
    this.onDismiss,
  });
}

class AppStateWidget extends StatefulWidget {
  final Widget child;
  final StateData stateData;
  final bool showOverlay;
  final Color? backgroundColor;
  final bool dismissible;

  const AppStateWidget({
    super.key,
    required this.child,
    required this.stateData,
    this.showOverlay = true,
    this.backgroundColor,
    this.dismissible = false,
  });

  @override
  State<AppStateWidget> createState() => _AppStateWidgetState();
}

class _AppStateWidgetState extends State<AppStateWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  bool _overlayVisible = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _handleInitialState();
  }

  void _handleInitialState() {
    if (widget.stateData.state != ViewState.idle) {
      _overlayVisible = true;
      _fadeController.forward();
      _scaleController.forward();
      
      if (widget.stateData.state == ViewState.loading) {
        _pulseController.repeat(reverse: true);
      }
    }
  }

  @override
  void didUpdateWidget(AppStateWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stateData.state != widget.stateData.state) {
      if (widget.stateData.state != ViewState.idle) {
        setState(() => _overlayVisible = true);
        _fadeController.forward();
        _scaleController.forward();
        
        if (widget.stateData.state == ViewState.loading) {
          _pulseController.repeat(reverse: true);
        } else {
          _pulseController.stop();
        }
      } else {
        _pulseController.stop();
        _fadeController.reverse();
        _scaleController.reverse().then((_) {
          if (mounted) {
            setState(() => _overlayVisible = false);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_overlayVisible) _buildOverlay(),
      ],
    );
  }

  Widget _buildOverlay() {
    return GestureDetector(
      onTap: widget.dismissible ? _dismissOverlay : null,
      child: IgnorePointer(
        ignoring: widget.stateData.state == ViewState.idle,
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                color: widget.backgroundColor ?? 
                       Theme.of(context).colorScheme.surface.withOpacity(0.85),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: _buildStateCard(),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStateCard() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.15),
            blurRadius: 32,
            offset: const Offset(0, 16),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStateIcon(),
            const SizedBox(height: 24),
            _buildStateTitle(),
            const SizedBox(height: 8),
            _buildStateMessage(),
            const SizedBox(height: 28),
            _buildStateActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildStateIcon() {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (widget.stateData.state) {
      case ViewState.loading:
        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      case ViewState.success:
        return Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 36,
          ),
        );
      case ViewState.error:
        return Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade400, Colors.red.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.error_rounded,
            color: Colors.white,
            size: 36,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStateTitle() {
    final title = widget.stateData.title ?? _getDefaultTitle();
    final colorScheme = Theme.of(context).colorScheme;
    
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildStateMessage() {
    if (widget.stateData.message == null) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    
    return Text(
      widget.stateData.message!,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface.withOpacity(0.7),
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildStateActions() {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (widget.stateData.state) {
      case ViewState.loading:
        return widget.dismissible 
          ? TextButton(
              onPressed: _dismissOverlay,
              child: Text(
                widget.stateData.actionText ?? 'Dismiss',
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
              ),
            )
          : const SizedBox.shrink();
      case ViewState.success:
        return _buildPrimaryButton(
          text: widget.stateData.actionText ?? 'Continue',
          onPressed: widget.stateData.onSuccess ?? _dismissOverlay,
          backgroundColor: Colors.green,
        );
      case ViewState.error:
        return Column(
          children: [
            if (widget.stateData.onRetry != null) ...[
              _buildPrimaryButton(
                text: widget.stateData.actionText ?? 'Try Again',
                onPressed: widget.stateData.onRetry!,
                backgroundColor: colorScheme.primary,
              ),
              const SizedBox(height: 12),
            ],
            _buildSecondaryButton(
              text: 'Dismiss',
              onPressed: _dismissOverlay,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    required Color backgroundColor,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface.withOpacity(0.7),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(
            color: colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  String _getDefaultTitle() {
    switch (widget.stateData.state) {
      case ViewState.loading:
        return 'Please Wait';
      case ViewState.success:
        return 'Success!';
      case ViewState.error:
        return 'Something Went Wrong';
      default:
        return '';
    }
  }

  void _dismissOverlay() {
    // Call the appropriate callback based on state
    switch (widget.stateData.state) {
      case ViewState.success:
        widget.stateData.onSuccess?.call();
        break;
      case ViewState.error:
      case ViewState.loading:
        widget.stateData.onDismiss?.call();
        break;
      default:
        break;
    }
    _pulseController.stop();
    _fadeController.reverse();
    _scaleController.reverse().then((_) {
      if (mounted) {
        setState(() => _overlayVisible = false);
      }
    });
  }
}

// Usage Example:
class ExampleUsage extends StatefulWidget {
  const ExampleUsage({super.key});

  @override
  _ExampleUsageState createState() => _ExampleUsageState();
}

class _ExampleUsageState extends State<ExampleUsage> {
  ViewState _currentState = ViewState.idle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('State Widget Demo')),
      body: AppStateWidget(
        stateData: StateData(
          state: _currentState,
          message: _getMessage(),
          onRetry: () {
            setState(() {
              _currentState = ViewState.loading;
            });
            // Simulate async operation
            Future.delayed(const Duration(seconds: 2), () {
              setState(() {
                _currentState = ViewState.success;
              });
            });
          },
          onSuccess: () {
            setState(() {
              _currentState = ViewState.idle;
            });
          },
          onDismiss: () {
            setState(() {
              _currentState = ViewState.idle;
            });
          },
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => _currentState = ViewState.loading),
                child: const Text('Show Loading'),
              ),
              ElevatedButton(
                onPressed: () => setState(() => _currentState = ViewState.success),
                child: const Text('Show Success'),
              ),
              ElevatedButton(
                onPressed: () => setState(() => _currentState = ViewState.error),
                child: const Text('Show Error'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _getMessage() {
    switch (_currentState) {
      case ViewState.loading:
        return 'Processing your request...';
      case ViewState.success:
        return 'Your operation completed successfully!';
      case ViewState.error:
        return 'Unable to complete the operation. Please check your connection and try again.';
      default:
        return null;
    }
  }
}