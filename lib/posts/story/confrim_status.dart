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
      bottomNavigationBar: BottomAppBar(
        elevation: 10.0,
        child: Container(
          constraints: BoxConstraints(maxHeight: 100.0),
          child: Flexible(
            child: TextFormField(
              style: TextStyle(
                fontSize: 15.0,
                color: Theme.of(context).textTheme.headline6!.color,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10.0),
                enabledBorder: InputBorder.none,
                border: InputBorder.none,
                hintText: "Type your caption",
                hintStyle: TextStyle(
                  color: Theme.of(context).textTheme.headline6!.color,
                ),
              ),
              onSaved: (val) {
                viewModel.setDescription(val!);
              },
              onChanged: (val) {
                viewModel.setDescription(val);
              },
              maxLines: null,
            ),
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
