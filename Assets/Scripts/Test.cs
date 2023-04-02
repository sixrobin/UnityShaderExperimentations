using RSLib.Extensions;
using UnityEngine;

public class Test : MonoBehaviour
{
    public float a = 45f;
    public float l = 0.5f;

    public Transform to;
    
    private void OnDrawGizmos()
    {
        Gizmos.color = Color.cyan;
        Gizmos.DrawLine(transform.position, this.to.position);
        RSLib.Debug.GizmosUtilities.DrawArrowHead3D(transform.position, to.position - transform.position, l, a);
    }
}
