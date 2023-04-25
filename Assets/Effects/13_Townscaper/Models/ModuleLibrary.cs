using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

[CreateAssetMenu(menuName = "ScriptableObject/ModuleLibrary")]

public class ModuleLibrary : ScriptableObject {

    // 导入的模型
    [SerializeField]
    private GameObject importedModules;

    // 这里用List<Module>是为了后续做波函数坍缩做准备，因为同一个bit，会对应多种可能的mesh模块。对于Marching Cube来说，只有一种
    private Dictionary<string, List<Module>> moduleLibrary = new Dictionary<string, List<Module>>();

    private void Awake() {
        ImportedModule();
    }

    public void ImportedModule() {
        // 暂时不考虑全0和全1
        for (int i = 1; i < 255; i++) {
            // 1 ~ 255 转换成二进制，八位，前面0填充    00000001 ~ 11111110
            moduleLibrary.Add(Convert.ToString(i, 2).PadLeft(8, '0'), new List<Module>());
        }

        foreach (Transform child in importedModules.transform) {
            Mesh mesh = child.GetComponent<MeshFilter>().sharedMesh;
            string name = child.name;

            string bit = name.Substring(0, 8);
            string sockets;
            if (name.Length == 8) {
                sockets = "aaaaaa";
            }
            else {
                sockets = name.Substring(9, 6);
            }

            moduleLibrary[bit].Add(new Module(name, mesh, 0, false));


            if (!Rotation_90_CheckEqual(bit)) {
                moduleLibrary[Bit_AfterRotate(bit, 1)].Add(new Module(Name_AfterRotate(bit, sockets, 1), mesh, 1, false));
                if (!Rotation_180_CheckEqual(bit)) {
                    moduleLibrary[Bit_AfterRotate(bit, 2)].Add(new Module(Name_AfterRotate(bit, sockets, 2), mesh, 2, false));
                    moduleLibrary[Bit_AfterRotate(bit, 3)].Add(new Module(Name_AfterRotate(bit, sockets, 3), mesh, 3, false));
                    if (!Flip_V_H_D_CheckEqual(bit)) {
                        moduleLibrary[Bit_AfterFlip(bit)].Add(new Module(Name_AfterFlip(bit, sockets), mesh, 0, true));
                        moduleLibrary[Bit_AfterRotate(Bit_AfterFlip(bit), 1)].Add(new Module(Name_AfterRotate(Name_AfterFlip(bit, sockets).Substring(0, 8), Name_AfterFlip(bit, sockets).Substring(9, 6), 1), mesh, 1, true));
                        moduleLibrary[Bit_AfterRotate(Bit_AfterFlip(bit), 2)].Add(new Module(Name_AfterRotate(Name_AfterFlip(bit, sockets).Substring(0, 8), Name_AfterFlip(bit, sockets).Substring(9, 6), 2), mesh, 2, true));
                        moduleLibrary[Bit_AfterRotate(Bit_AfterFlip(bit), 3)].Add(new Module(Name_AfterRotate(Name_AfterFlip(bit, sockets).Substring(0, 8), Name_AfterFlip(bit, sockets).Substring(9, 6), 3), mesh, 3, true));
                    }
                }
            }
        }
        Debug.Log(moduleLibrary.Count);
    }

    private string Bit_AfterRotate(string bit, int time) {
        string res = bit;
        for (int i = 0; i < time; i++) {
            res = res[3] + res.Substring(0, 3) + res[7] + res.Substring(4, 3);
        }
        return res;
    }

    private string Name_AfterRotate(string bit, string sockets, int time) {
        string res = sockets;
        for (int i = 0; i < time; i++) {
            res = res.Substring(3, 1) + res.Substring(0, 3) + res.Substring(4);
            // res = res.Substring(3, 1) + res.Substring(0, 3) + res.Substring(4, 2);
        }
        return Bit_AfterRotate(bit, time) + "_" + res;
    }
    
    private string Bit_AfterFlip(string bit) {
        return bit[3].ToString() + bit[2] + bit[1] + bit[0]+ bit[7]+ bit[6]+ bit[5]+ bit[4];
    }

    private string Name_AfterFlip(string bit, string sockets) {
        string res = sockets;
        res = res.Substring(2, 1) + res.Substring(1, 1) + res.Substring(0, 1) + res.Substring(3, 1) + res.Substring(4);
        // res = res.Substring(2, 1) + res.Substring(1, 1) + res.Substring(0, 1) + res.Substring(3, 1) + res.Substring(4, 2);
        return Bit_AfterFlip(bit) + "_" + res;
    }

    private bool Rotation_90_CheckEqual(string bit) {
        return bit[0] == bit[1] && bit[1] == bit[2] && bit[2] == bit[3] && bit[4] == bit[5] && bit[5] == bit[6] && bit[6] == bit[7];
    }

    private bool Rotation_180_CheckEqual(string bit) {
        return bit[0] == bit[2] && bit[1] == bit[3] && bit[4] == bit[6] && bit[5] == bit[7];
    }

    private bool Flip_V_H_D_CheckEqual(string bit) {
        string symmetry_Vertical = bit[3].ToString() + bit[2] + bit[1] + bit[0] + bit[7] + bit[6] + bit[5] + bit[4];
        string symmetry_Horizontal = bit[1].ToString() + bit[0] + bit[3] + bit[2] + bit[5] + bit[4] + bit[7] + bit[6];
        // 两个斜对角线
        string symmetry_45 = bit[0].ToString() + bit[3] + bit[2] + bit[1] + bit[4] + bit[7] + bit[6] + bit[5];
        string symmetry_135 = bit[2].ToString() + bit[1] + bit[0] + bit[3] + bit[6] + bit[5] + bit[4] + bit[7];
        return (bit == symmetry_Vertical) || (bit == symmetry_Horizontal) || (bit == symmetry_45) || (bit == symmetry_135);
    }

    public List<Module> GetModules(string name) {
        List<Module> res;
        if (moduleLibrary.TryGetValue(name, out res)) {
            return res;
        }
        return null;
    }
}
