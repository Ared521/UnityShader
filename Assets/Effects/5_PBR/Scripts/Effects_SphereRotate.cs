using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Effects_SphereRotate : MonoBehaviour
{
    public int rotateSpeed = 2;
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        transform.Rotate(Vector3.up * -rotateSpeed * 0.1f, Space.World);
    }
}
