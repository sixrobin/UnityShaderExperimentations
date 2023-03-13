using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class Zebra : MonoBehaviour
{
    [Range(0.01f, 1.0f)]
    public float _size = 0.5f;
    [Range(0.1f, 5.0f)]
    public float _saturation = 1;
    [Range(-10.0f, 10.0f)]
    public float _speed = 1.0f;

    public enum myAxis { Horizontal, Vertical };
    public myAxis axis;
    int _axis = 0;

    Camera cam;

    private Shader zebraShader = null;
	private Material zebraMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        zebraShader = Shader.Find("MyShaders/Zebra");
        zebraMaterial = CheckShader(zebraShader, zebraMaterial);

        return isSupported;
    }

    protected Material CheckShader(Shader s, Material m)
    {
        if (s == null)
        {
            Debug.Log("Missing shader on " + ToString());
            this.enabled = false;
            return null;
        }

        if (s.isSupported == false)
        {
            Debug.Log("The shader " + s.ToString() + " is not supported on this platform");
            this.enabled = false;
            return null;
        }

        cam = GetComponent<Camera>();
        cam.renderingPath = RenderingPath.UsePlayerSettings;

        m = new Material(s);
        m.hideFlags = HideFlags.DontSave;

        if (s.isSupported && m && m.shader == s)
            return m;

        return m;
    }

    void OnDestroy()
    {
#if UNITY_EDITOR
        DestroyImmediate(zebraMaterial);
#else
        Destroy(zebraMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}

        if (axis == myAxis.Horizontal)
            _axis = 0;
        if (axis == myAxis.Vertical)
            _axis = 1;

        zebraMaterial.SetFloat("_size", 1 - _size);
        zebraMaterial.SetFloat("_saturation", _saturation);
        zebraMaterial.SetFloat ("_speed", _speed);
        zebraMaterial.SetInt("_axis", _axis);
			
		Graphics.Blit (source, destination, zebraMaterial);
	}
}
