# 仿真模型搭建
## 前言

只是记录以下在从Solidworks里导出到ubuntu下做方针的一系列过程和自己踩过的一些坑，并且提醒一些注意事项，以及一些还存在的问题。

## 一、下载安装Solidworks

1. 去CSDN上找教程安装Solidworks，也可以去找你的机械，让他们帮忙给安装包。不过请注意，队里的Solidworks**版本**是2020的，也有2023的版本，请和你的机械做好沟通，不要装错版本导致版本太低打不开文件了。
2. 注意！！尽量不要安装好之后再卸载！！不然注册表问题会非常复杂，如果是在是因为版本或者其他原因卸载了，然后出现了注册表问题，请寻找你的机械请求帮助（这里有人曾经因为这个问题折腾了一天也没有解决，最后选择了放弃，最后的最后选择的重装系统）。

## 二、从Solidworks里导出urdf文件

主要参考这篇[博客](https://blog.csdn.net/weixin_45168199/article/details/105755388)

1. 首先，你需要从你的机械那里获得车的solidworks文件，注意一下版本问题

2. 下载sw_urdf_exporter插件

   - 从[Ros官网](http://wiki.ros.org/sw_urdf_exporter)下载sw2urdfSetup.exe文件，下载的时候会跳到github，需要梯子帮忙下载（<font color = red>快普及梯子！快！</font>），如果你实在是没有梯子，找到你的视觉，请求他的帮助。
   - 下载的时候可能会注意到sw_urdf_exporter的版本已经很久没有更新了，看文档是更新到21版本的solidworks，不过实际测试中，22版也是可以用的，但不清楚23的可不可以用~~（需要一些小白鼠）~~。

3. 在Solidworks里配置每个link的点和坐标系以及旋转轴。
   **具体看[博客](https://blog.csdn.net/weixin_45168199/article/details/105755388)。**

   - 建议在配置的时候给每个点和坐标系都重新命名，这样在后面选择每个joint和link的坐标轴和旋转轴的时候比较方便（主要是可能会出现大量的重复工作，用数字标注的时候选择会很麻烦）。

4. 利用安装好的sw_urdf_exporter插件进行配置。
   插件在<font color = blue>工具—File—Export as URDF</font>中

   - base_link：首先配置base_link，是作为最为基础的，不会有旋转或其他运动的部分存在，一般选择底盘的部分，但不包含轮子。

   - Reference Axis：旋转轴，不在base_link中出现。

   - link name / joint name：一般写成对应的部件的名称，后面加<font color = blue>_name<font color = black> / </font>_joint</font>。

   - Global Origin Coordinate System / Reference Coordinate System：坐标系，直接选择之前配置好的坐标系就可以。

   - link components：指这个link包含了哪些零部件，需要手动在图中选中这些部分。一般来说选中就可以了，但我在选中的过程中发现，如果选中的是装配体，可能会出现零部件的缺失，需要点开装配体，逐个选中最小的部分才行。（可能是22版本的问题）

   - child links：更改数量就可以增加与该link**直接相连**的link的数量。

   - joint type：joint的类型，主要分为：

     - <font color = blue>continuous</font>: 旋转关节，可以绕单轴无限旋转
     - <font color = blue>revolute</font>: 旋转关节，类似于 continues,但是有旋转角度限制
     - prismatic: 滑动关节，沿某一轴线移动的关节，有位置极限
     - planer: 平面关节，允许在平面正交方向上平移或旋转
     - floating: 浮动关节，允许进行平移、旋转运动
     - fixed: 固定关节，不允许运动的特殊关节

     根据实际的情况来选择就行，但一般只有pitch需要用revolute，其他的用continuous就行。revolute需要设置limit的值（这个我没设过，所以不太清楚0到底在哪里以及到底顺时针是正还是逆时针是正）。

    配置完之后点Preview and Export就行。最后点击Export URDF and Meshes。生成需要一段时间。

5. 检查文件

   - 导出文件中有一个名为meshes的文件夹，里面放的是所有的link对应的文件，可以根据文件的大小来确定是否全部正常生成了对应的模型。保险起见可以拉到Solidworks里检查。（主要是到ubuntu里跑了之后才发现不对还要切系统，太麻烦了！）
   - 如果有问题就重新做第4步的配置。这个时候除了坐标系和旋转轴都是没有变动的，而坐标系和旋转轴会变成auto，这个时候需要重新选择，否则生成会报错。（要记得<font color = red>保存</font>！否则下次打开文件之前的配置就没有了）

## 三、导入到ubuntu中测试

1. 首先需要一个ROS的工作空间。

   ```	
   mkdir sim/src
   cd sim/src
   catkin_init_workspace
   ```

2. 把之前在windows下生成的整个文件夹copy到src下，再在sim文件夹下catkin_make。如果出现catkin package can't find的问题，可以直接把catkin的包copy过去（主要这样比较快，我路径问题折腾了很久都没搞好）。

3. 运行launch文件

   launch文件夹下，display.launch是在rviz里显示的，gazebo.launch是在gazebo中运行的。以下为两种显示的具体内容。

   ### rviz

   1. 运行launch文件

      ```
      source devel/setup.bash
      roslaunch src/模型文件夹名称/launch/display.launch
      ```

      

   2. 在Fixed Frame中选择base_link

      ![image-20231105211155304](/home/bletilla/.config/Typora/typora-user-images/image-20231105211155304.png)

   2. Add中选择RobotModel

      ![image-20231105211421762](/home/bletilla/.config/Typora/typora-user-images/image-20231105211421762.png)

   3. 然后就可以在rviz里看到车的模型了。这个时候可以检查一下是不是所有需要的部分都有了。接着就可以在窗口里调整每个joint的角度，从而看到实际上模型的运动状态了。

      ![image-20231105211611275](/home/bletilla/.config/Typora/typora-user-images/image-20231105211611275.png)

   ### gazebo

   1. 运行launch文件

      ```
      source devel/setup.bash
      roslaunch src/模型文件夹名称/launch/gazebo.launch
      ```

   2. 等待……然后就可以看到车在gazebo中自由地运动了。自由运动可能是因为模型本身有重量，然后没有配平导致的。

## 四、修改已生成的文件，配置控制用接口

主要参考[博客](https://blog.csdn.net/weixin_41420355/article/details/104379449)

1. 修改已经生成的urdf文件

   - copy一份<font color = blue>.urdf</font>文件，并把后缀改成<font color = blue>.xacro</font>。
   - 将原先的

   ```
   <robot
     name="robot_name">
   ```

   改为

   ```
   <robot name="robot_name" xmlns:xacro="http://ros.org/wiki/xacro">
   ```

   - 针对joint标签

     - 添加<font color = blue>dynamics</font>标签，主要用于描述关节的物理属性，例如阻尼值、物理静摩擦力等，经常在动力学仿真中用到。

     - 添加<font color = blue>limit</font>标签，主要用于描述运动的一些极限值，包括关节运动的上下限位置、速度限制、力矩限制等。

     - 例如：

       ```
         <joint
           name="joint1"
           type="revolute">
           <origin
             xyz="0 0 0.04"
             rpy="0 0 -1.5708" />
           <parent
             link="base_link" />
           <child
             link="link1" />
           <axis
             xyz="0 0 1" />
           <dynamics damping="0.7"/>
           <limit effort="300" velocity="1" lower="-2.96" upper="2.96"/>
         </joint>
       ```

     - 注意name和type是和之前的对应的，具体还可以加入的内容可以参考[博客](https://blog.csdn.net/qq_71734878/article/details/128000279)

   - 在文件最后</joint>之后，</robot>之前加入：

     ```
       <!-- Transmissions for ROS Control -->
       <xacro:macro name="transmission_block" params="tran_name joint_name motor_name">
         <transmission name="${tran_name}">
             <type>transmission_interface/SimpleTransmission</type>
             <joint name="${joint_name}">
                 <hardwareInterface>hardware_interface/EffortJointInterface</hardwareInterface>
             </joint>
             <actuator name="$motor_name">
                 <hardwareInterface>hardware_interface/EffortJointInterface</hardwareInterface>
                 <mechanicalReduction>1</mechanicalReduction>
             </actuator>
         </transmission>
       </xacro:macro>
     
       <xacro:transmission_block tran_name="tran1" joint_name="joint1" motor_name="motor1"/>
       <xacro:transmission_block tran_name="tran2" joint_name="joint2" motor_name="motor2"/>
       <xacro:transmission_block tran_name="tran3" joint_name="joint3" motor_name="motor3"/>
       <xacro:transmission_block tran_name="tran4" joint_name="joint4" motor_name="motor4"/>
       <xacro:transmission_block tran_name="tran5" joint_name="joint5" motor_name="motor5"/>
       <xacro:transmission_block tran_name="tran6" joint_name="joint6" motor_name="motor6"/>
       <!--gazebo plugin-->
       <gazebo>
         <plugin name="gazebo_ros_control" filename="libgazebo_ros_control.so">
             <robotNamespace>/robot_name</robotNamespace>
         </plugin>
       </gazebo>
     ```

     - 注意此处<font color = blue>xacro</font>标签之间的内容是整体模板的配置，对应的是下面的<font color = blue>xacro:transmission_block</font>开头的标签。和前面配置好的joint对应就可以了。这样就作了一次统一的配置。具体数量根据本身的joint的数量来配置就可以。

     - <font color = blue>hardwareInterface</font>标签中的内容是指在控制的时候用的是位置控制还是力矩控制或者速度控制。<font color = blue>PositionJointInterface</font>是位置控制，<font color = blue>EffortJointInterface</font>是力矩控制，<font color = blue>VelocityJointInterface</font>是速度控制。一般选择力矩控制就可以。

     - <font color = blue>mechanicalReduction</font>标签中的内容指的是电机的减速比，可以根据电机的实际情况进行修改。

     - 也可以根据实际所需要的单独进行配置。改成

       ```
       <xacro:macro name="transmission_block" params="tran_name joint_name motor_name">
           <transmission name="tran_name">
               <type>transmission_interface/SimpleTransmission</type>
               <joint name="joint_name">
                   <hardwareInterface>hardware_interface/EffortJointInterface</hardwareInterface>
               </joint>
               <actuator name="motor_name">
                   <hardwareInterface>hardware_interface/EffortJointInterface</hardwareInterface>
                   <mechanicalReduction>1</mechanicalReduction>
               </actuator>
           </transmission>
         </xacro:macro>
       ```

2. 修改display.launch

   - 可以copy一份再修改。

   - 把其中的一个param <font color = blue>"robot_discription"</font>的一整个标签修改为如下的形式:

     ```
       <param name="robot_description"
         command="$(find xacro)/xacro --inorder '$(find robot_package)/urdf/robot.xacro'" />
     ```

   - 具体的robot根据实际的文件名进行修改

3. 修改gazebo.launch

   - 同样可以copy一份再修改

   - 在include后面加入以下内容：

     ```
       <param name="robot_description"
         command="$(find xacro)/xacro --inorder '$(find robot_package)/urdf/robot.xacro'" />
     ```
     
    - 并对<font color = blue>spawn_model</font>标签里的<font color = blue>arg</font>部分进行修改：
   
      ```
      args="-urdf -model newaxis -param robot_description"
      ```
   
4. 测试修改的launch文件是否能够成功运行。

## 五、创建控制部分

主要参考[博客](https://blog.csdn.net/weixin_41420355/article/details/104379449)

1. 新建功能包

   - 在src文件夹下创建新的功能包

     ```
     cd ~/new_ws/src
     catkin_create_pkg robot_control controller_manager joint_state_controller robot_state_publisher
     cd sixaxis_control
     mkdir config
     mkdir launch
     ```

2. 设定参数文件

   - 在config中新建一个robot_control.yaml文件:

     ```
     sixaxis:
       # Publish all joint states -----------------------------------
       joint_state_controller:
         type: joint_state_controller/JointStateController
         publish_rate: 50  
     
       # Position Controllers ---------------------------------------
       joint1_position_controller:
         type: effort_controllers/JointPositionController
         joint: joint1
         pid: {p: 100.0, i: 0.0, d: 0.0}
       joint2_position_controller:
         type: effort_controllers/JointPositionController
         joint: joint2
         pid: {p: 100.0, i: 0.0, d: 0.0}
       joint3_position_controller:
         type: effort_controllers/JointPositionController
         joint: joint3
         pid: {p: 100.0, i: 0.0, d: 0.0}
       joint4_position_controller:
         type: effort_controllers/JointPositionController
         joint: joint4
         pid: {p: 100.0, i: 0.0, d: 0.0}
       joint5_position_controller:
         type: effort_controllers/JointPositionController
         joint: joint5
         pid: {p: 100.0, i: 0.0, d: 0.0}
       joint6_position_controller:
         type: effort_controllers/JointPositionController
         joint: joint6
         pid: {p: 100.0, i: 0.0, d: 0.0}
     ```

   - type详情：

     - <font color = blue>/</font>前面的表示对joint的输出为力矩输出，对应前面xacro文件中的hardwareInterface，如果改成其他的了这里也要做对应的修改，改成<font color = blue>position_controllers</font>或<font color = blue>velocity_controllers</font>。
     - <font color = blue>/</font>后面的表示对joint的输入为位置输入，也就是通过ros_control发布的数据表示的是位置。同理，也有力矩以及速度的输入方式，可以根据需要改成<font color = blue>JointVelocityController</font>或者<font color = blue>JointEffortController</font>。在实际用代码控制的时候一般是用的力矩控制，如果只是测试可以用速度或者位置控制。

   - 如果使用了速度输入或者位置输入，需要配置相应的PID进行调参。

3. 编写launch文件

   - 在launch文件夹下新建robot_control.launch

     ```
     <launch>
     
       <!-- Load joint controller configurations from YAML file to parameter server -->
       <rosparam file="$(find robot_control)/config/robot_control.yaml" command="load"/>
     
       <!-- load the controllers -->
       <node name="controller_spawner" pkg="controller_manager" type="spawner" respawn="false"
         output="screen" ns="/robot_name" args="joint1_position_controller joint2_position_controller joint3_position_controller joint4_position_controller joint5_position_controller joint6_position_controller joint_state_controller"/>
     
       <!-- convert joint states to TF transforms for rviz, etc -->
       <node name="robot_state_publisher" pkg="robot_state_publisher" type="robot_state_publisher"
         respawn="false" output="screen">
         <remap from="/joint_states" to="/robot_name/joint_states" />
       </node>
     
     </launch>
     ```

   - joint1_position_controller根据实际的joint进行修改，对应每一个需要控制的joint，主要在后面rqt里使用。

   - robot部分对应实际的文件。

4. 全部完成之后catkin_make。

## 六、测试

主要参考[博客](https://blog.csdn.net/weixin_41420355/article/details/104379449)

1. 开4个终端，分别输入以下命令：

   ```
   roscore
   roslaunch robot gazebo.launch
   roslaunch robot_control sixaxis_control.launch
   rosrun rqt_gui rqt_gui
   ```

   - roscore需要在所有的ros都关掉之后才能正常运行。
   - 如果没有把包输入到路径当中，则可以进到工作空间里，source之后再直接指明路径运行。

2. 通过rqt_gui进行控制

   - 点击plugin选择Topics下的Message Publisher。
   - 加入话题，例如下图，对应修改即可。
   - ![image-20231106201825320](/home/bletilla/.config/Typora/typora-user-images/image-20231106201825320.png)
   - 最后对话题打上钩就可以发布话题了，之后修改data的数据就可以看到模型在gazebo中的运动情况了。

## 已经做了但没有成功/做完的部分

- 搭建了小车的运动场景，但没有成功让小车在这个环境里跑。参考了这篇[博客](https://blog.csdn.net/qq_39362509/article/details/124533551)。
- 使用MoveIt配置了车子并生成了文件，但是没有实际使用。参考[博客](https://blog.csdn.net/weixin_41995979/article/details/81515711)。

## 等待实现的部分

- 增加传感器，但是没有实际运用。参考[博客](https://blog.csdn.net/qq_39362509/article/details/124533587)。
- 刚体动力学仿真。参考[廖佬github](https://github.com/qiayuanl/rm_suspension)。

## 参考

https://blog.csdn.net/weixin_45168199/article/details/105755388

https://blog.csdn.net/qq_45685327/article/details/130308842

https://blog.csdn.net/weixin_41420355/article/details/104379449

https://blog.csdn.net/qq_71734878/article/details/128000279

https://www.twblogs.net/a/5ed61163af116bb777bfd64b

https://zhuanlan.zhihu.com/p/182417621

https://blog.csdn.net/qq_39362509/article/details/124533551

https://blog.csdn.net/weixin_41995979/article/details/81515711

https://blog.csdn.net/qq_39362509/article/details/124533587

https://github.com/qiayuanl/rm_suspension

