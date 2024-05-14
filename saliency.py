import tensorflow as tf
import numpy as np
import matplotlib.pyplot as plt

# 加载预训练的卷积神经网络模型
model = tf.keras.applications.VGG16(weights='imagenet', include_top=True)
preprocess_input = tf.keras.applications.vgg16.preprocess_input

# 选择待分析的图像
image_path = 'path_to_your_image.jpg'
image = tf.keras.preprocessing.image.load_img(image_path, target_size=(224, 224))
input_image = tf.keras.preprocessing.image.img_to_array(image)
input_image = np.expand_dims(input_image, axis=0)
input_image = preprocess_input(input_image)

# 创建用于计算saliency map的新模型
saliency_model = tf.keras.Model(
    inputs=model.inputs,
    outputs=model.get_layer('block1_conv1').output  # 选择第一层卷积的输出作为输出层
)

# 计算梯度
with tf.GradientTape() as tape:
    tape.watch(input_image)
    conv_outputs = saliency_model(input_image)
    class_index = np.argmax(model.predict(input_image))
    loss = conv_outputs[0, :, :, class_index]

# 计算输入图像对于输出类别的梯度
grads = tape.gradient(loss, input_image)[0]

# 对梯度进行归一化处理
grads_norm = tf.math.divide_no_nan(grads, tf.reduce_max(tf.abs(grads)))

# 创建显著性图
saliency_map = tf.reduce_mean(grads_norm, axis=-1)

# 可视化显著性图和原始图像
plt.figure(figsize=(10, 5))
plt.subplot(1, 2, 1)
plt.imshow(image)
plt.title('Original Image')
plt.axis('off')

plt.subplot(1, 2, 2)
plt.imshow(saliency_map, cmap='hot')
plt.title('Saliency Map')
plt.axis('off')

plt.tight_layout()
plt.show()
