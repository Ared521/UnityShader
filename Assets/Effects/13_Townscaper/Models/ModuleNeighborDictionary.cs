using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ModuleNeighborDictionary {
    public static Dictionary<string, HashSet<string>> neighborDictionary = new Dictionary<string, HashSet<string>>() {
        { "a", new HashSet<string>{ "a", "e", "f" } },
        { "b", new HashSet<string>{ "b", "e", "f" } },
        { "c", new HashSet<string>{ "c", "e", "f" } },
        { "d", new HashSet<string>{ "d", "e", "f" } },
        { "e", new HashSet<string>{ "e", "f" } },
        { "f", new HashSet<string>{ "f" } }
    };
}
