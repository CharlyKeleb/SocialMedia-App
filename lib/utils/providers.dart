import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:social_media_app/view_models/auth/login_view_model.dart';
import 'package:social_media_app/view_models/auth/posts_view_model.dart';
import 'package:social_media_app/view_models/auth/register_view_model.dart';
import 'package:social_media_app/view_models/conversation/conversation_view_model.dart';
import 'package:social_media_app/view_models/profile/edit_profile_view_model.dart';
import 'package:social_media_app/view_models/user/user_view_model.dart';
import 'package:social_media_app/utils/constants.dart';



List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => RegisterViewModel()),
  ChangeNotifierProvider(create: (_) => LoginViewModel()),
  ChangeNotifierProvider(create: (_) => PostsViewModel()),
  ChangeNotifierProvider(create: (_) => EditProfileViewModel()),
  ChangeNotifierProvider(create: (_) => ConversationViewModel()),
  ChangeNotifierProvider(create: (_) => UserViewModel()),
  ChangeNotifierProvider(create: (_) => ThemeNotifier()),
];
