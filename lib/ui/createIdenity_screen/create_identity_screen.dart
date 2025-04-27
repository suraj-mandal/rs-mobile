import 'package:flutter/material.dart';
import 'package:retroshare/ui/createIdenity_screen/create_signed_identity.dart';
import 'package:retroshare/ui/createIdenity_screen/pseudo_identity.dart';

class CreateIdentityScreen extends StatefulWidget {
  const CreateIdentityScreen({super.key, this.isFirstId = false});
  final bool isFirstId;

  @override
  CreateIdentityScreenState createState() => CreateIdentityScreenState();
}

class CreateIdentityScreenState extends State<CreateIdentityScreen>
    with SingleTickerProviderStateMixin {
  late final Animation<Color?> _leftTabIconColor;
  late final Animation<Color?> _rightTabIconColor;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(vsync: this, length: widget.isFirstId ? 1 : 2);
    _leftTabIconColor =
        ColorTween(begin: const Color(0xFFF5F5F5), end: Colors.white)
            .animate(_tabController.animation!);
    _rightTabIconColor =
        ColorTween(begin: Colors.white, end: const Color(0xFFF5F5F5))
            .animate(_tabController.animation!);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const appBarHeight = kToolbarHeight;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Identity'),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: (appBarHeight - 40) / 2,
                  top: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AnimatedBuilder(
                      animation: _tabController.animation!,
                      builder: (BuildContext context, Widget? child) {
                        return GestureDetector(
                          onTap: () {
                            _tabController.animateTo(0);
                          },
                          child: Container(
                            width: 2 * appBarHeight,
                            decoration: BoxDecoration(
                              color:
                                  _leftTabIconColor.value ?? Colors.grey[200],
                              borderRadius:
                                  BorderRadius.circular(appBarHeight / 2),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Center(
                                child: Text(
                                  'Signed Identity',
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    if (!widget.isFirstId)
                      AnimatedBuilder(
                        animation: _tabController.animation!,
                        builder: (BuildContext context, Widget? child) {
                          return GestureDetector(
                            onTap: () {
                              _tabController.animateTo(1);
                            },
                            child: Container(
                              width: 2 * appBarHeight,
                              decoration: BoxDecoration(
                                color: _rightTabIconColor.value ??
                                    Colors.grey[200],
                                borderRadius:
                                    BorderRadius.circular(appBarHeight / 2),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Center(
                                  child: Text(
                                    ' Pseudo Identity',
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SignedIdenityTab(widget.isFirstId, key: UniqueKey()),
                  if (!widget.isFirstId)
                    PseudoSignedIdenityTab(widget.isFirstId, key: UniqueKey()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
