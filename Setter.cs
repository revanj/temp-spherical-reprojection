using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Setter : MonoBehaviour
{
    // Attach to an object that has a Renderer component,
    // and use material with the shader below.
    public Transform planeTransform;
    public void Update()
    {
        // Construct a rotation matrix and set it for the shader
        var relativeCenter = planeTransform.InverseTransformPoint(transform.TransformPoint(Vector3.zero));
        var relativeRotation = Matrix4x4.Rotate(Quaternion.Inverse(planeTransform.rotation) * transform.rotation);
        // Quaternion rot = Quaternion.Euler(0, 0, Time.time * rotateSpeed);
        // Matrix4x4 m = Matrix4x4.TRS(Vector3.zero, rot, Vector3.one);
        GetComponent<Renderer>().material.SetMatrix("_CenterRotation", relativeRotation);
        GetComponent<Renderer>().material.SetVector("_TransformedCenter", relativeCenter);
    }
}
