using UnityEngine;

public class DungeonMasterPlayer : MonoBehaviour
{
    [SerializeField, Min(0f)] private float _moveDuration = 0.25f;
    [SerializeField, Min(0f)] private float _rotateDuration = 0.25f;

    private Transform _transform;
    private bool _motionCoroutineRunning;
    
    private System.Collections.IEnumerator MoveCoroutine(Vector3 to)
    {
        this._motionCoroutineRunning = true;
        Vector3 from = this._transform.position;
        
        for (float t = 0f; t < 1f; t += Time.deltaTime / this._moveDuration)
        {
            this.transform.position = Vector3.Lerp(from, to, t);
            yield return null;
        }

        this.transform.position = to;
        this._motionCoroutineRunning = false;
    }

    private System.Collections.IEnumerator RotateCoroutine(Vector3 lookPosition)
    {
        this._motionCoroutineRunning = true;

        Vector3 position = this._transform.position;
        Vector3 initLookDirection = position + this._transform.forward;
        
        for (float t = 0f; t < 1f; t += Time.deltaTime / this._rotateDuration)
        {
            Vector3 lerpLookDirection = Vector3.Lerp(initLookDirection, lookPosition, t);
            this.transform.LookAt(lerpLookDirection, Vector3.up);
            yield return null;
        }
        
        this.transform.LookAt(lookPosition, Vector3.up);
        this._motionCoroutineRunning = false;
    }

    private void Awake()
    {
        this._transform = this.transform;
    }

    private void Update()
    {
        if (this._motionCoroutineRunning)
            return;
        
        if (Input.GetKeyDown(KeyCode.UpArrow))
            this.StartCoroutine(this.MoveCoroutine(this._transform.position + this._transform.forward));
        else if (Input.GetKeyDown(KeyCode.DownArrow))
            this.StartCoroutine(this.MoveCoroutine(this._transform.position - this._transform.forward));
        else if (Input.GetKeyDown(KeyCode.RightArrow))
            this.StartCoroutine(this.RotateCoroutine(this._transform.position + this._transform.right));
        else if (Input.GetKeyDown(KeyCode.LeftArrow))
            this.StartCoroutine(this.RotateCoroutine(this._transform.position - this._transform.right));
    }
}