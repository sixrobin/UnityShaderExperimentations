using UnityEngine;

public class CellularAutomatonCamera : MonoBehaviour
{
    public Camera Camera;
    public float ZoomedInSize = 0.05f;
    public float ZoomedOutSize = 5f;
    public float ZoomDuration = 5f;

    private System.Collections.IEnumerator ZoomInCoroutine()
    {
        for (float t = 0f; t < 1f; t += Time.deltaTime / this.ZoomDuration)
        {
            this.Camera.orthographicSize = Mathf.Lerp(this.ZoomedOutSize, this.ZoomedInSize, t * (2f - t));
            yield return null;
        }

        this.Camera.orthographicSize = this.ZoomedInSize;
    }

    private System.Collections.IEnumerator ZoomOutCoroutine()
    {
        for (float t = 0f; t < 1f; t += Time.deltaTime / this.ZoomDuration)
        {
            this.Camera.orthographicSize = Mathf.Lerp(this.ZoomedInSize, this.ZoomedOutSize, t * t);
            yield return null;
        }

        this.Camera.orthographicSize = this.ZoomedOutSize;
    }
    
    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Z))
            this.StartCoroutine(this.ZoomInCoroutine());
        else if (Input.GetKeyDown(KeyCode.S))
            this.StartCoroutine(this.ZoomOutCoroutine());
    }
}
