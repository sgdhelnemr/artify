import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/painting.dart';
import '../providers/painting_provider.dart';
import '../utils/validators.dart';

/// Add a new painting, or edit an existing one when [painting] is provided.
class PaintingFormScreen extends StatefulWidget {
  final Painting? painting;
  const PaintingFormScreen({super.key, this.painting});

  @override
  State<PaintingFormScreen> createState() => _PaintingFormScreenState();
}

class _PaintingFormScreenState extends State<PaintingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _artist;
  late final TextEditingController _year;
  late final TextEditingController _price;
  late final TextEditingController _image;
  late final TextEditingController _description;
  bool _saving = false;

  bool get _isEdit => widget.painting != null;

  @override
  void initState() {
    super.initState();
    final p = widget.painting;
    _title = TextEditingController(text: p?.title ?? '');
    _artist = TextEditingController(text: p?.artist ?? '');
    _year = TextEditingController(text: p?.year.toString() ?? '');
    _price = TextEditingController(text: p == null ? '' : p.price.toStringAsFixed(0));
    _image = TextEditingController(text: p?.image ?? '');
    _description = TextEditingController(text: p?.description ?? '');
  }

  @override
  void dispose() {
    for (final c in [_title, _artist, _year, _price, _image, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final provider = context.read<PaintingProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final painting = Painting(
      id: widget.painting?.id ?? 0,
      title: _title.text.trim(),
      artist: _artist.text.trim(),
      year: int.parse(_year.text.trim()),
      price: double.parse(_price.text.trim()),
      image: _image.text.trim(),
      description: _description.text.trim(),
    );

    final error = _isEdit
        ? await provider.updatePainting(painting)
        : await provider.addPainting(painting);

    if (!mounted) return;
    setState(() => _saving = false);

    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(content: Text(_isEdit ? 'Painting updated ✅' : 'Painting added ✅')),
    );
  }

  InputDecoration _dec(String label, {String? hint, IconData? icon}) => InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon),
        border: const OutlineInputBorder(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit painting' : 'Add painting')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _title,
                textInputAction: TextInputAction.next,
                decoration: _dec('Title', icon: Icons.title),
                validator: (v) => Validators.required(v, 'Title'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _artist,
                textInputAction: TextInputAction.next,
                decoration: _dec('Artist', icon: Icons.brush),
                validator: (v) => Validators.required(v, 'Artist'),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _year,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: _dec('Year', icon: Icons.calendar_today),
                      validator: Validators.year,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _price,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
                      decoration: _dec('Price (\$)', icon: Icons.attach_money),
                      validator: Validators.price,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _image,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                decoration: _dec(
                  'Image (optional)',
                  hint: 'https://... or assets/images/1.jpg',
                  icon: Icons.image,
                ),
                validator: Validators.imagePath,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _description,
                maxLines: 4,
                decoration: _dec('Description', icon: Icons.notes),
                validator: (v) => Validators.required(v, 'Description'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isEdit ? 'Save changes' : 'Add painting'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
