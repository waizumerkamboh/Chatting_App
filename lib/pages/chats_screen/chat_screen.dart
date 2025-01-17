import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:we_chat/Model/UserModel.dart';
import 'package:we_chat/config/colors.dart';
import 'package:we_chat/controller/chat_controller/chat_controller.dart';
import 'package:we_chat/controller/profile_controller/profile_controller.dart';
import 'package:we_chat/pages/UserProfile/profile_page.dart';
import 'package:we_chat/pages/chats_screen/widget/chat_bubble.dart';
import 'package:we_chat/pages/chats_screen/widget/type_message.dart';

import '../../config/images.dart';

class ChatScreen extends StatelessWidget {
  final UserModel userModel;
  ChatScreen({super.key, required this.userModel});
  ChatController chatController = Get.put(ChatController());
  ProfileController profileController = Get.put(ProfileController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            Get.to(UserProfilePage(
              userModel: userModel,
            ));
          },
          child: Padding(
              padding: const EdgeInsets.all(5),
              child: Container(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: userModel.profileImage ??
                          ImageAssets.defaultProfileUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    )),
              )),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.call)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.video_call)),
        ],
        title: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            Get.to(UserProfilePage(
              userModel: userModel,
            ));
          },
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userModel.name ?? "User",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  StreamBuilder(
                      stream: chatController.getStatus(userModel.id!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('');
                        } else {
                          return Text(
                            snapshot.data!.status ?? "",
                            style: TextStyle(
                                fontSize: 12,
                                color: snapshot.data!.status == "Online"
                                    ? dPrimaryColor
                                    : dOnContainerColor),
                          );
                        }
                      })
                ],
              ),
            ],
          ),
        ),
      ),
      body: Padding(
          padding:
              const EdgeInsets.only(bottom: 10, top: 10, left: 10, right: 10),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    StreamBuilder(
                        stream: chatController.getMessages(userModel.id!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text("Error: ${snapshot.error}"),
                            );
                          }
                          if (snapshot.data == null) {
                            return const Center(
                              child: Text('No Messages'),
                            );
                          } else {
                            return ListView.builder(
                                reverse: true,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  DateTime timestamp = DateTime.parse(
                                      snapshot.data![index].timestamp!);
                                  String formattedTime =
                                      DateFormat('hh:mm a').format(timestamp);
                                  return ChatBubbleScreen(
                                    message: snapshot.data![index].message!,
                                    isComing: snapshot
                                            .data![index].receiverId ==
                                        profileController.currentUser.value.id,
                                    time: formattedTime,
                                    status: "read",
                                    imageUrl:
                                        snapshot.data![index].imageUrl ?? "",
                                  );
                                });
                          }
                        }),
                    Obx(() => (chatController.selectedImagePath.value != "")
                        ? Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  height: 500,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.contain,
                                        image: FileImage(
                                          File(
                                            chatController.selectedImagePath.value
                                          )
                                        )),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      borderRadius: BorderRadius.circular(15)),
                                ),
                                Positioned(
                                  right: 0,
                                  child: IconButton(
                                      onPressed: (){
                                        chatController.selectedImagePath.value == "";
                                      },
                                      icon: const Icon(Icons.close)
                                  ),
                                )
                              ],
                            ),
                          )
                        : Container())
                  ],
                ),
              ),
              TypeMessage(userModel: userModel),
            ],
          )),
    );
  }
}
