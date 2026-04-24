import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

class HelpDeskCatalog {
  static Catalog asCatalog() {
    return Catalog(
      items: [
        // 1. Column for layout
        CatalogItem(
          name: 'Column',
          dataSchema: S.object(properties: {
            'components': S.list(items: S.object()),
          }),
          widgetBuilder: (itemContext) {
            final props = itemContext.data as Map<String, dynamic>;
            final components = props['components'] as List? ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: components.map((c) => itemContext.renderComponent(c)).toList(),
            );
          },
        ),

        // 2. Product Card
        CatalogItem(
          name: 'ProductCard',
          dataSchema: S.object(properties: {
            'name': S.string(),
            'price': S.string(),
            'imageUrl': S.string(),
          }),
          widgetBuilder: (itemContext) {
            final props = itemContext.data as Map<String, dynamic>;
            final context = itemContext.buildContext;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (props['imageUrl'] != null)
                    Image.network(
                      props['imageUrl'] as String,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(height: 150, color: Colors.grey.shade200, child: const Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(props['name'] as String? ?? 'Product', style: Theme.of(context).textTheme.titleLarge),
                        Text(props['price'] as String? ?? '', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // 3. FAQ Card
        CatalogItem(
          name: 'FAQCard',
          dataSchema: S.object(properties: {'question': S.string(), 'answer': S.string()}),
          widgetBuilder: (itemContext) {
            final props = itemContext.data as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ExpansionTile(
                title: Text(props['question'] as String? ?? 'Question'),
                children: [Padding(padding: const EdgeInsets.all(16), child: Text(props['answer'] as String? ?? 'Answer'))],
              ),
            );
          },
        ),

        // 4. Order Status
        CatalogItem(
          name: 'OrderStatus',
          dataSchema: S.object(properties: {'orderId': S.string(), 'status': S.string(), 'estimatedDelivery': S.string()}),
          widgetBuilder: (itemContext) {
            final props = itemContext.data as Map<String, dynamic>;
            return Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order #${props['orderId']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(children: [const Icon(Icons.local_shipping, size: 20), const SizedBox(width: 8), Text('Status: ${props['status']}')]),
                  Text('Estimated Delivery: ${props['estimatedDelivery']}'),
                ],
              ),
            );
          },
        ),

        // 5. Promo Card
        CatalogItem(
          name: 'PromoCard',
          dataSchema: S.object(properties: {'title': S.string(), 'code': S.string(), 'discount': S.string(), 'expiry': S.string()}),
          widgetBuilder: (itemContext) {
            final props = itemContext.data as Map<String, dynamic>;
            return Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.orange.shade400, Colors.red.shade400]), borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(props['title'] as String? ?? 'Special Offer', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text('Discount: ${props['discount']}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: Text('CODE: ${props['code']}', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 8),
                  Text('Expires: ${props['expiry']}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            );
          },
        ),

        // 6. Comparison Table
        CatalogItem(
          name: 'ComparisonTable',
          dataSchema: S.object(properties: {'title': S.string(), 'items': S.list(items: S.object(properties: {'label': S.string(), 'values': S.list(items: S.string())})), 'headers': S.list(items: S.string())}),
          widgetBuilder: (itemContext) {
            final props = itemContext.data as Map<String, dynamic>;
            final headers = (props['headers'] as List? ?? []).cast<String>();
            final items = (props['items'] as List? ?? []);
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(props['title'] as String? ?? 'Comparison', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: headers.map((h) => DataColumn(label: Text(h, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                        rows: items.map((item) {
                          final row = item as Map<String, dynamic>;
                          final values = (row['values'] as List? ?? []).map((v) => v.toString()).toList();
                          final List<DataCell> cells = [DataCell(Text(row['label'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w500)))];
                          cells.addAll(values.map((v) => DataCell(Text(v))));
                          while (cells.length < headers.length) { cells.add(const DataCell(Text('-'))); }
                          return DataRow(cells: cells.take(headers.length).toList());
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // 7. Support Contact
        CatalogItem(
          name: 'SupportContact',
          dataSchema: S.object(properties: {'type': S.string(), 'value': S.string()}),
          widgetBuilder: (itemContext) {
            final props = itemContext.data as Map<String, dynamic>;
            final type = props['type'] as String? ?? 'Contact';
            final isPhone = type.toLowerCase() == 'phone';
            return ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(isPhone ? Icons.phone : Icons.email),
              label: Text('$type: ${props['value']}'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            );
          },
        ),
      ],
      catalogId: 'help_desk',
    );
  }
}
