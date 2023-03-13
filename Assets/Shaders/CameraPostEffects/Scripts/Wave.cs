using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class Wave : MonoBehaviour
{
    [Range(-10.0f, 10.0f)]
    public float _amplitudeX = 1.0f;
    [Range(-10.0f, 10.0f)]
    public float _amplitudeY = 1.0f;
    [Range(-1.0f, 1.0f)]
    public float _frequencyX = 0.5f;
    [Range(-1.0f, 1.0f)]
    public float _frequencyY = -0.5f;
    [Range(-2.0f, 2.0f)]
    public float _speed = 1.0f;

    Camera cam;

    private Shader waveShader = null;
    private Material waveMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        waveShader = Shader.Find("MyShaders/Wave");
        waveMaterial = CheckShader(waveShader, waveMaterial);

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
        DestroyImmediate(waveMaterial);
#else
        Destroy(waveMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources() == false)
		{
			Graphics.Blit (source, destination);
			return;
		}
			
		waveMaterial.SetFloat ("_amplitudeX", _amplitudeX);
		waveMaterial.SetFloat ("_amplitudeY", _amplitudeY);
		waveMaterial.SetFloat ("_frequencyX", _frequencyX);
		waveMaterial.SetFloat ("_frequencyY", _frequencyY);
		waveMaterial.SetFloat ("_speed", _speed);

		Graphics.Blit (source, destination, waveMaterial);
	}
}
