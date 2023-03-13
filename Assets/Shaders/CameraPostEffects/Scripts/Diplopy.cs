using UnityEngine;

[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]

public class Diplopy : MonoBehaviour
{
    public enum AxisR { LateralR, LateralL, Horizontal, Vertical };
    public AxisR myAxisR;
    int _axisR = 0;

    [Range(-10.0f, 10.0f)]
    public float _amplitudeRed = 0.0f;

    public enum AxisG { LateralR, LateralL, Horizontal, Vertical };
    public AxisG myAxisG;
    int _axisG = 0;

    [Range(-10.0f, 10.0f)]
    public float _amplitudeGreen = 0.0f;

    public enum AxisB { LateralR, LateralL, Horizontal, Vertical };
    public AxisB myAxisB;
    int _axisB = 0;

    [Range(-10.0f, 10.0f)]
    public float _amplitudeBlue = 0.0f;

    Camera cam;

    private Shader diplopyShader = null;
    private Material diplopyMaterial = null;
    bool isSupported = true;

    void Start()
    {
        CheckResources();
    }

    public bool CheckResources()
    {
        diplopyShader = Shader.Find("MyShaders/Diplopy");
        diplopyMaterial = CheckShader(diplopyShader, diplopyMaterial);

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
        DestroyImmediate(diplopyMaterial);
#else
        Destroy(diplopyMaterial);
#endif
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
        if (CheckResources() == false)
        {
            Graphics.Blit(source, destination);
            return;
        }

        if (myAxisR == AxisR.LateralR)
            _axisR = 0;
        if (myAxisR == AxisR.LateralL)
            _axisR = 1;
        if (myAxisR == AxisR.Horizontal)
            _axisR = 2;
        if (myAxisR == AxisR.Vertical)
            _axisR = 3;

        if (myAxisG == AxisG.LateralR)
            _axisG = 0;
        if (myAxisG == AxisG.LateralL)
            _axisG = 1;
        if (myAxisG == AxisG.Horizontal)
            _axisG = 2;
        if (myAxisG == AxisG.Vertical)
            _axisG = 3;

        if (myAxisB == AxisB.LateralR)
            _axisB = 0;
        if (myAxisB == AxisB.LateralL)
            _axisB = 1;
        if (myAxisB == AxisB.Horizontal)
            _axisB = 2;
        if (myAxisB == AxisB.Vertical)
            _axisB = 3;

        diplopyMaterial.SetInt("_axisR", _axisR);
        diplopyMaterial.SetFloat("_amplitudeRed", _amplitudeRed);

        diplopyMaterial.SetInt("_axisG", _axisG);
        diplopyMaterial.SetFloat("_amplitudeGreen", _amplitudeGreen);

        diplopyMaterial.SetInt("_axisB", _axisB);
        diplopyMaterial.SetFloat("_amplitudeBlue", _amplitudeBlue);

        Graphics.Blit (source, destination, diplopyMaterial);
	}
}
