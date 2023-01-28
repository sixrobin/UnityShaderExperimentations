using UnityEngine;

// [ExecuteInEditMode]
public class Rotator : MonoBehaviour
{
    public bool IsOn;
    public bool Invert;
    public float Speed;

    private void Update()
    {
        if (this.IsOn)
            this.transform.Rotate(0f, this.Speed * Time.deltaTime * (this.Invert ? -1 : 1), 0f, Space.World);
    }
}