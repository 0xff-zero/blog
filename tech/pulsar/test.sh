path=$pwd
app_name=${path##*/}
# jar 包路径
path_name=`pwd`/`ls *webapp/target/*.jar`
echo $path_name
# jar包名称
echo $(bashname "$path_name")
echo ${full_name##*/} 
jar_name=${full_name##*/} 

echo $jar_name

jar_name_no_ext=${jar_name%%*-}

app_version=${jar_name##*-}
echo $pkg_version
#app_name=${jar_name%-*} 
#echo $app_name


out -k APP_NAME -val $app_name
out -k APP_VERSION -val $app_version
# /root/workspace/