using UnityEngine;

[ExecuteInEditMode]
public class Billboard : MonoBehaviour
{
    public bool IsOn;
    public bool Invert;
    public Transform Target;

    private void Update()
    {
        if (!this.IsOn)
            return;
        
        Vector3 targetPosition = this.Target ? this.Target.position : Camera.main.transform.position;
        Transform thisTransform = this.transform;
        thisTransform.forward = this.Invert ? thisTransform.position - targetPosition : targetPosition - thisTransform.position;
    }
}
