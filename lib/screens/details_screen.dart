import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/comment.dart';
import '../models/painting.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/painting_provider.dart';
import '../routes.dart';
import '../utils/error_helper.dart';
import '../utils/validators.dart';
import '../widgets/painting_image.dart';

class DetailsScreen extends StatefulWidget {
  final int paintingId;
  const DetailsScreen({super.key, required this.paintingId});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentCtrl = TextEditingController();
  late Future<List<Comment>> _commentsFuture;
  bool _posting = false;

  @override
  void initState() {
    super.initState();
    _commentsFuture = context.read<PaintingProvider>().fetchComments(widget.paintingId);
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _reloadComments() {
    setState(() {
      _commentsFuture = context.read<PaintingProvider>().fetchComments(widget.paintingId);
    });
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  Future<void> _addComment() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _posting = true);
    final error = await context
        .read<PaintingProvider>()
        .addComment(widget.paintingId, _commentCtrl.text);
    if (!mounted) return;
    setState(() => _posting = false);
    if (error != null) {
      _snack(error);
      return;
    }
    _commentCtrl.clear();
    FocusScope.of(context).unfocus();
    _reloadComments();
  }

  Future<void> _deleteComment(int id) async {
    final error = await context.read<PaintingProvider>().deleteComment(id);
    if (!mounted) return;
    if (error != null) {
      _snack(error);
    } else {
      _reloadComments();
    }
  }

  Future<void> _confirmAndDelete(Painting p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete painting?'),
        content: Text('"${p.title}" will be removed permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final provider = context.read<PaintingProvider>();
    final cart = context.read<CartProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final error = await provider.deletePainting(p);
    if (error == null) {
      await cart.remove(p.id);
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text('"${p.title}" deleted')));
    } else {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaintingProvider>();
    final cart = context.watch<CartProvider>();
    final p = provider.byId(widget.paintingId);

    if (p == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This painting is no longer available')),
      );
    }

    final liked = provider.isLiked(p.id);
    final inCart = cart.contains(p.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(p.title),
        actions: [
          IconButton(
            icon: Icon(
              liked ? Icons.favorite : Icons.favorite_border,
              color: liked ? Colors.red : null,
            ),
            onPressed: () => provider.toggleLike(p.id),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'edit') {
                Navigator.pushNamed(context, AppRoutes.form, arguments: p);
              } else if (v == 'delete') {
                _confirmAndDelete(p);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PaintingImage(path: p.image, height: 300),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${p.artist} • ${p.year}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  Text(p.description),
                  const SizedBox(height: 12),
                  Text(
                    '\$${p.price.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: inCart
                          ? null
                          : () {
                              cart.add(p.id);
                              _snack('Added to cart ✅');
                            },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: Text(inCart ? 'Already in cart' : 'Add to Cart'),
                    ),
                  ),
                  const Divider(height: 32),
                  _buildComments(),
                  const SizedBox(height: 8),
                  Form(
                    key: _formKey,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _commentCtrl,
                            validator: Validators.comment,
                            decoration: InputDecoration(
                              hintText: 'Write a comment...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onFieldSubmitted: (_) => _addComment(),
                          ),
                        ),
                        _posting
                            ? const Padding(
                                padding: EdgeInsets.all(14),
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: _addComment,
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComments() {
    final myId = context.read<AuthProvider>().userId;
    return FutureBuilder<List<Comment>>(
      future: _commentsFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return Column(
            children: [
              Text(friendlyError(snap.error!)),
              TextButton(onPressed: _reloadComments, child: const Text('Retry')),
            ],
          );
        }
        final comments = snap.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comments (${comments.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (comments.isEmpty) const Text('No comments yet. Be the first! 💬'),
            ...comments.map(
              (c) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(c.text),
                subtitle: Text(c.userEmail),
                trailing: c.userId == myId
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteComment(c.id),
                      )
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}
