using UnityEngine;

public class Rotator : MonoBehaviour
{
    public bool IsOn;
    public float Speed;

    private void Update()
    {
        if (this.IsOn)
            this.transform.Rotate(0f, this.Speed * Time.deltaTime, 0f, Space.World);
    }
}