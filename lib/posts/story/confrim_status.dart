import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/view_models/status/status_view_model.dart';
import 'package:social_media_app/widgets/indicators.dart';

class ConfirmStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    StatusViewModel viewModel = Provider.of<StatusViewModel>(context);
    return Scaffold(
      body: LoadingOverlay(
        isLoading: viewModel.loading,
        progressIndicator: circularProgress(context),
        child: Center(
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: Image.file(viewModel.mediaUrl!),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
        onPressed: () => viewModel.uploadStatus(context),
      ),
    );
  }
}
