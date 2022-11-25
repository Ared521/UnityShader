# Stencil Test
> ## 详细原理参考：[图形学：深度与模板测试](https://blog.csdn.net/whitebreeze/article/details/118097525)

## 流程: 
* 1、窗户shader：Reference(模板值)随便设置一个(以1为例)；Comparison(比较，是否通过)设置为always；PassFront设置为Replace(表现为：窗户显示的区域，也就是覆盖的区域，这块区域的模板值为前面设置的Reference，也就是1(因为以1为例))；ZWrite Mode设置为On(默认就是On)。
* 2、球shader：ZTest设置为Greater，确保球在窗户后面能够通过深度测试，能够渲染；模板值设置为1，Comparison设置为 Equal，表示相等即可通过模板测试。因为球的Reference和窗户的Reference都是1，所以通过了模板测试，球可以正确的显示出来。
* 3、两个shader的Queue Index设置，窗户要小于球，保证窗户先渲染，先有模板，才能有后面的球跟模板值做模板测试。ZWrite Mode设置为On(默认就是On)。
