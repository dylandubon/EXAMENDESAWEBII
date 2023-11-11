
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:productos/providers/product_form_provider.dart';
import 'package:productos/services/products_service.dart';
import 'package:productos/ui/input_decorations.dart';
import 'package:productos/widgest/product_image.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatelessWidget{
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context);
    return ChangeNotifierProvider(
      create: ( _ )=> ProductFormProvider(productService.selectedProduct),
      child: _ProductScreenBody(productService: productService),
      );
  }

}

class _ProductScreenBody extends StatelessWidget {
  final ProductService productService;

  const _ProductScreenBody({
    Key? key, 
    required this.productService
  }): super(key: key);


  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              ProductImage(url: productService.selectedProduct.picture),
              Positioned(
                top :60,
                left: 20,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(), 
                  icon: const Icon(Icons.arrow_back,size: 40,color: Colors.white,))
                  ),
              Positioned(
                top: 60,
                left: 20,
                child: IconButton(
                  onPressed: () async{
                    final  picker = ImagePicker();
                    final PickedFile? pickedFile = (await picker.pickImage(
                      source: ImageSource.camera, imageQuality: 100)) as PickedFile?;
                    if (pickedFile == null){
                      print('No selecciono nada');
                      return;
                    }
                    productService.updateSelectedProductImage(pickedFile.path);
                  },
                  icon: const Icon(Icons.camera_alt_rounded, size: 40,color: Colors.white,),
                ),
              )
              ),
              _ProductForm()
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked ,
      floatingActionButton: FloatingActionButton(
        onPressed: productService.isSaving ? null :
        () async {
          if(!productForm.isValidForm()) return;
          final String? imageUrl = await productService.uploadImage();
          //Validar si la imagen se subio de forma correcta
          if( imageUrl != null) productForm.product.picture = imageUrl;
          //Guardar , mendiante post al API
          await productService.saveOrCreateProduct(productForm.product);

        },
        child: productService.isSaving ? const CircularProgressIndicator(color: Colors.white60) : 
        const Icon(Icons.save_outlined)),
    );
  }}

  class _ProductForm extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);
    final product = productForm.product;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: _buildBoxDecoration(),
        child: Form(
          key: productForm.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              const SizedBox(height: 10),
              TextFormField(
                initialValue: product.name,
                onChanged: (value) => product.name = value,
                validator: (value){
                  if(value == null || value.isEmpty)
                  return "EL campo nombre es obligatorio";
                
                  return null;},
                  decoration: InputDecorations.authInputDecoration(
                    hintText: "Nombre del producto", labelText: "Nombre")
              ),
              const SizedBox(height: 30),
              TextFormField(
                initialValue: '${product.price}',
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}'))
                ],
                onChanged: (value) {
                  if(double.tryParse(value)== null){
                    product.price = 0;
                  }else{
                    product.price = double.parse(value);
                  }
                },
                keyboardType: TextInputType.number,
                decoration: InputDecorations.authInputDecoration(hintText: "Q150", labelText: "Precio"),

              ),
              const SizedBox(height: 30,),
              SwitchListTile.adaptive(value: product.available, 
              activeColor: Colors.indigo,
              hoverColor: Colors.blueGrey,
              title:  const Text("Disponible"),
              onChanged: productForm.updateAvailability(product.available)),
              const SizedBox(height: 30,)


            ],
          )),
      ),      
    );
  }
  
    BoxDecoration _buildBoxDecoration()=>  BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25) ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.05),
          offset: const Offset(0,5),
          blurRadius: 5
        )
      ]
    );
  }