import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makers/Controller/complaint_controller.dart';
import 'package:makers/Screens/response_page.dart';

class Complaint extends StatelessWidget {
  const Complaint({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ComplaintController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Submit Complaint',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFF9B0062).withOpacity(1),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ResponsePage()),
              );
            },
            icon: const Icon(Icons.feedback_outlined, size: 22),
            tooltip: 'View Responses',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Form Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Selection
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFF8FAFC),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: controller.selectedCategory.value,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xFF64748B),
                                size: 20,
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E293B),
                              ),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  controller.selectedCategory.value = newValue;
                                }
                              },
                              items: controller.categories.map((
                                String category,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Priority Selection
                      const Text(
                        'Priority Level',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => Row(
                          children: [1, 2, 3]
                              .map(
                                (value) => Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        controller.priority.value = value,
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        right: value < 3 ? 8 : 0,
                                      ),
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color:
                                            controller.priority.value == value
                                            ? controller.getPriorityColor(value)
                                            : const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color:
                                              controller.priority.value == value
                                              ? controller.getPriorityColor(
                                                  value,
                                                )
                                              : const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          controller.getPriorityText(value),
                                          style: TextStyle(
                                            color:
                                                controller.priority.value ==
                                                    value
                                                ? Colors.white
                                                : const Color(0xFF64748B),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Complaint Text Area
                      const Text(
                        'Describe your complaint',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.complaintController,
                        maxLines: 5,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Please provide detailed information about your complaint...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 239, 239, 240),
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your complaint details';
                          }
                          if (value.trim().length < 10) {
                            return 'Please provide more details (minimum 10 characters)';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Submit Button
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.submitComplaint,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF9B0062).withOpacity(1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              disabledBackgroundColor: const Color(0xFF94A3B8),
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.send, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Submit Complaint',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            255,
                            250,
                            251,
                            252,
                          ).withOpacity(1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Color(0xFF3B82F6),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your complaint will be reviewed soon. You will receive updates here.',
                          style: TextStyle(
                            color: const Color(0xFF1E293B).withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
