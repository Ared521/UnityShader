using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 表示每个模块的信息
[System.Serializable]
public class Module {
    public string name;
    public Mesh mesh;

    public string bit;
    
    // Socket指的是截面命名  比如 aaaaaa，baabaa
    public string[] sockets = new string[6];

    public static Dictionary<int, int> neighborSocket = new Dictionary<int, int>() { {0, 3}, {1, 2}, {2, 1}, {3, 0}, {4, 5}, {5, 4} };

    // 输入的模块是否存在旋转和镜像所产生的新模块要通过这两个变量来判断。因为有些模块的X轴的镜像与自己不同或与自己沿着XZ轴旋转180度之后的不同 
    // 是否存在旋转
    public int rotation;
    // 是否是镜像
    public bool flip;

    public Module(string name, Mesh mesh, int rotation, bool flip) {
        this.name = name;
        this.mesh = mesh;
        this.rotation = rotation;
        this.flip = flip;

        this.bit = name.Substring(0, 8);

        if (name.Length != 8) {
            sockets[0] = name.Substring(9, 1);
            sockets[1] = name.Substring(10, 1);
            sockets[2] = name.Substring(11, 1);
            sockets[3] = name.Substring(12, 1);
            sockets[4] = name.Substring(13, 1);
            sockets[5] = name.Substring(14, 1);
        }
        else {
            sockets[0] = "a";
            sockets[1] = "a";
            sockets[2] = "a";
            sockets[3] = "a";
            sockets[4] = "a";
            sockets[5] = "a";
        }
    }
}
