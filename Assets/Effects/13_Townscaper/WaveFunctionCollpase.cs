using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 表示每个模块的信息
[System.Serializable]
public class WaveFunctionCollpase : MonoBehaviour
{
    private WorldMaster worldMaster;
    private GridGenerator gridGenerator;
    private ModuleLibrary moduleLibrary;

    public List<Slot> resetSlots = new List<Slot>();

    public List<Slot> cur_CollapseSlots = new List<Slot>();
    public Slot cur_CollapseSlot;

    public Stack<Slot> propagateSlotStack = new Stack<Slot>();
    public Slot cur_propagateSlot;

    private int WFC_Number = 0;

    public Stack<Slot> collapseSlotStack = new Stack<Slot>();
    public Stack<List<Slot>> collapseSlotsStack = new Stack<List<Slot>>();


    private void Awake() {
        worldMaster = GetComponentInParent<WorldMaster>();
        gridGenerator = worldMaster.gridGenerator;
        moduleLibrary = Instantiate(gridGenerator.moduleLibrary);
    }

    public void WFC() {
        Reset();
        CollapseAndPropagate();
        UpdateModule();
        WFC_Number++;
        // Debug.Log("完成 " + WFC_Number + " 次WFC");
    }

    // 将全部的块的可能性(slot.possibleModules)重置
    private void Reset() {
        while (resetSlots.Count > 0) {
            // 取出第一个待传递重置的Slot
            Slot cur_resetSlot = resetSlots[0];
            resetSlots.RemoveAt(0);

            // 尝试向该Slot相邻的Slot传递重置
            SubQuad_Cube[] neighbors = cur_resetSlot.subQuad_Cube.neighbors;
            
            // Debug.Log(neighbors.Length); 

            foreach (SubQuad_Cube subQuad_Cube in neighbors) {
                if (subQuad_Cube != null && subQuad_Cube.isActive && !subQuad_Cube.slot.reset) {
                    // 判断相邻slot是否为独立模块
                    // 只有非独立模块，才会传递重置
                    bool independNeighbor = true;
                    foreach (Vertex_Y vertex_Y in cur_resetSlot.subQuad_Cube.neighborVertices[subQuad_Cube]) {
                        if (vertex_Y.isActive) {
                            independNeighbor = false;
                            break;
                        }
                    }
                    if (!independNeighbor) {
                        subQuad_Cube.slot.ResetSlot(moduleLibrary);
                        // 加入当前待坍缩的slots变量
                        if (cur_CollapseSlots.Contains(subQuad_Cube.slot) == false) {
                            cur_CollapseSlots.Add(subQuad_Cube.slot);
                        }
                        resetSlots.Add(subQuad_Cube.slot);
                        Debug.Log("重置");
                    }
                }
            }
        }
    }

    // 坍缩与传递坍缩，直至所有的slot可能性都坍缩为1
    private void CollapseAndPropagate() {
        while (cur_CollapseSlots.Count > 0) {
            // 当 propagateSlotStack.Count == 0 代表当前 cur_CollapseSlots 的坍缩传播完成，此时还有待坍缩的slot，接着选择可能性最小的slot接着坍缩，直到所有slot都坍缩完成
            if (propagateSlotStack.Count == 0) {
                GetCollapseSlot();
                Collapse();
            }
            Propagate();
        }
    }

    // 先从可能性最少的块开始坍缩会大大提高坍缩效率
    public void GetCollapseSlot() {
        // 先获取当前最少的可能性
        int minPossibility = cur_CollapseSlots[0].possibleModules.Count;
        foreach (Slot slot in cur_CollapseSlots) {
            if (slot.possibleModules.Count < minPossibility) {
                minPossibility = slot.possibleModules.Count;
            }
        }

        // 找到的当前最少的可能性的slot之后，可能存在多个相同的最少可能性的结果，那么为了保证坍缩结果的唯一性，那么就要保证每次在相同的可能性的情况下，选择结果的同一性
        // 也就是选择index最小的slot
        bool findFirst = false;
        foreach (Slot slot in cur_CollapseSlots) {
            if (slot.possibleModules.Count == minPossibility) {
                if (findFirst == false) {
                    cur_CollapseSlot = slot;
                    findFirst = true;
                }
                else if (cur_CollapseSlot.subQuad_Cube.index > slot.subQuad_Cube.index) {
                    cur_CollapseSlot = slot;
                }
            }
        }
    }

    // 采用伪随机的模式
    public void Collapse() {

        // 存储当前状态 也即存储需要回溯的所有状态：当前坍缩的slot，当前待坍缩slot的集合，当前所有块的可能性
        // 当前可能性大于1时，才回溯，因为当可能性为1时，没必要回溯这一步，直接回溯上一步重新坍缩
        bool backtracingAvailable = (cur_CollapseSlot.possibleModules.Count > 1);
        if (backtracingAvailable) {
            collapseSlotStack.Push(cur_CollapseSlot);
            collapseSlotsStack.Push(cur_CollapseSlots.ConvertAll( x=> x ));

            // 存储之前的可能性结果
            foreach (Slot slot in gridGenerator.slots) {
                slot.pre_possibleModules.Push(slot.possibleModules);
            }
        }



        // 使用指定的种子值初始化 Random 类的新实例
        System.Random random = new System.Random(cur_CollapseSlot.subQuad_Cube.index);
        // random.Next() 返回非负随机数
        int chooseModule = random.Next() % cur_CollapseSlot.possibleModules.Count;
        // 也即选择一个经过坍缩了的得到的Module
        cur_CollapseSlot.Collapse(chooseModule);
        cur_CollapseSlots.Remove(cur_CollapseSlot);

        propagateSlotStack.Push(cur_CollapseSlot);


        // 在坍缩结束之后将此次坍缩选择的可能性移除
        if (backtracingAvailable) {
            List<Module> modules = cur_CollapseSlot.pre_possibleModules.Pop();
            modules.Remove(cur_CollapseSlot.possibleModules[0]);
            cur_CollapseSlot.pre_possibleModules.Push(modules);
        }
    }

    // 传递坍缩：去除不可能的module来传递     i 就是sockets的位置，如果两个位置对不上，就删除possibleModule里的这个module
    // 进入该函数的都是当前 cur_propagateSlot 的neighbors，把他们中不可能的 module 都移除，
    public void ConstrainPossibility(SubQuad_Cube[] neighbors, Dictionary<int, HashSet<string>> possibleSockets, int i) {
        // 将得到的List独立出来，不影响原有list
        List<Module> possibleModules = neighbors[i].slot.possibleModules.ConvertAll( x=> x );
        
        // 遍历所有的Module，去除不可能的 
        foreach(Module module in neighbors[i].slot.possibleModules) {
            // possibleSockets是计算的当前cur_propagateSlot，这里的neighbors是cur_propagateSlot的neighbor，这两个判断标记信息是否能够对上
            // possibleSockets[i]表示：sockets第i个位置，可以放置的标记信息，是一个hashset类型，意思是可以有多个可能的标记信息
            // 比如第 1 个位置，标记信息可以是set(a, b)，   那么如果module.sockets[Module.neighborSocket[i]])是 c, 那么标记信息就对不上，对上对不上要看ModuleNeighborDictionary这个类的静态成员变量
            // 对不上就把当前这个neighbor的这个module删除
            if (!possibleSockets[i].Contains(module.sockets[Module.neighborSocket[i]])) {
                possibleModules.Remove(module);

                // 将 neighbor 也Push到待传递栈里，用于进一步的坍缩传递
                if (!propagateSlotStack.Contains(neighbors[i].slot)) {
                    propagateSlotStack.Push(neighbors[i].slot);
                }
            }
        }
        neighbors[i].slot.possibleModules = possibleModules;
    }

    public void Propagate() {
        cur_propagateSlot = propagateSlotStack.Pop();

        // Sockets的六个位置，每个位置存入所有标记信息
        Dictionary<int, HashSet<string>> possibleSockets = new Dictionary<int, HashSet<string>>();
        for (int i = 0; i < 6; i++) {
            possibleSockets[i] = new HashSet<string>();
            foreach(Module module in cur_propagateSlot.possibleModules) {
                foreach (string socket in ModuleNeighborDictionary.neighborDictionary[module.sockets[i]]) {
                    possibleSockets[i].Add(socket);
                }
            }
        }

        SubQuad_Cube[] neighbors = cur_propagateSlot.subQuad_Cube.neighbors;
        
        // 遍历所有的neighbor，当存在activate的neighbor时，传递坍缩
        for (int i = 0; i < 6; i++) {
            if (neighbors[i] != null && neighbors[i].isActive) {
                ConstrainPossibility(neighbors, possibleSockets, i);

                if (neighbors[i].slot.possibleModules.Count == 0) {
                    Backtracing();
                    break;
                }
            }
        }
    }

    public void  Backtracing() {
        Debug.Log("回溯");
        cur_CollapseSlot = collapseSlotStack.Pop();
        cur_CollapseSlots = collapseSlotsStack.Pop();
        foreach (Slot slot in gridGenerator.slots) {
            slot.possibleModules = slot.pre_possibleModules.Pop();
            propagateSlotStack.Clear();
            Collapse();
        }
    }

    // 在坍缩结束之后，updateModule时清空回溯的stack
    public void ClearBacktracingStack() {
        collapseSlotStack.Clear();
        collapseSlotsStack.Clear();
        foreach (Slot slot in gridGenerator.slots) {
            slot.pre_possibleModules.Clear();
        }
        cur_CollapseSlot = null;
        cur_propagateSlot = null;
    }

    private void UpdateModule() {
        ClearBacktracingStack();

        foreach (Slot slot in gridGenerator.slots) {
            slot.UpdateModule(slot.possibleModules[0]);
        }
    }
}
