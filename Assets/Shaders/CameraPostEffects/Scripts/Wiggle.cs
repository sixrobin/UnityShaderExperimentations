using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
	
public class Wiggle : MonoBehaviour
{
    [Range(0.0f, 10f)]
    public float _amplitudeX = 5;
    [Range(0.0f, 10f)]
    public float _amplitudeY = 5;
    [Range(0.0f, 5.0f)]
    public float _distortionX = 2.0f;
    [Range(0.0f, 5.0f)]
    public float _distortionY = 2.0f;
    [Range(0.0f, 5.0f)]
    public float _speed = 2.0f;

    Camera cam;
    	
    private Shader wiggleShader = null;
	private Material wiggleMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        wiggleShader = Shader.Find("MyShaders/Wiggle");
        wiggleMaterial = CheckShader(wiggleShader, wiggleMaterial);

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
        DestroyImmediate(wiggleMaterial);
#else
        Destroy(wiggleMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}
          
		wiggleMaterial.SetFloat ("_amplitudeX", _amplitudeX);
		wiggleMaterial.SetFloat ("_amplitudeY", _amplitudeY);
		wiggleMaterial.SetFloat ("_distortionX", _distortionX);
		wiggleMaterial.SetFloat ("_distortionY", _distortionY);
		wiggleMaterial.SetFloat ("_speed", _speed);

		Graphics.Blit (source, destination, wiggleMaterial);
	}
}
