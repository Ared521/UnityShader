using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ColliderSystem : MonoBehaviour
{
    private WorldMaster worldMaster;
    [SerializeField]
    private GroundCollider groundCollider;
    [SerializeField]
    private SlotColliderSystem slotColliderSystem;

    private void Awake() {
        worldMaster = GetComponentInParent<WorldMaster>();
    }

    private void Start() {
        groundCollider.CreateCollider(worldMaster.gridGenerator.GetGrid());
    } 
    public SlotColliderSystem GetSlotColliderSystem() {
        return slotColliderSystem;
    }
}
