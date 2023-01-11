# 区别和使用
## implementation和api
implementation和api是取代之前的compile的，其中api和compile是一样的效果，implementation有所不同，通过implementation依赖的库只能自己库本身访问，举个例子，A依赖B，B依赖C，如果B依赖C是使用的implementation依赖，那么在A中是访问不到C中的方法的，如果需要访问，请使用api依赖

## compile only
compile only和provided效果是一样的，只在编译的时候有效， 不参与打包

## runtime only
runtimeOnly 和 apk效果一样，只在打包的时候有效，编译不参与

## test implementation
testImplementation和testCompile效果一样，在单元测试和打包测试apk的时候有效

## debug implementation
debugImplementation和debugCompile效果相同， 在debug模式下有效

## release implementation
releaseImplementation和releaseCompile效果相同，只在release模式和打包release包情况下有效