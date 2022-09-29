Shader "EXO/Freude"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _WingsTex ("Wings Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        _SmoothStepA ("SmoothStep A", Float) = 0
        _SmoothStepB ("SmoothStep B", Float) = 0.5
        _ReplacedColor ("Replaced Color", Color) = (0,1,0,1)
        [Toggle]
        _DebugMask ("Debug Mask", float) = 0
        
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1,1,1,1)
        [HideInInspector] _Flip ("Flip", Vector) = (1,1,1,1)
        [PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
        [PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend One OneMinusSrcAlpha

        CGPROGRAM
        #pragma target 3.0
        #pragma surface surf Lambert vertex:vert nofog nolightmap nodynlightmap keepalpha noinstancing
        #pragma multi_compile_local _ PIXELSNAP_ON
        #pragma multi_compile _ ETC1_EXTERNAL_ALPHA
        #include "UnitySprites.cginc"
        #pragma shader_feature _DEBUGMASK_ON

        sampler2D _WingsTex;
        float4 _ReplacedColor;
        float _SmoothStepA;
        float _SmoothStepB;
        
        struct Input
        {
            float2 uv_MainTex;
            float2 uv_WingsTex;
            float4 screenPos;
            fixed4 color;
            fixed4 wings_color;
        };
        
        void vert (inout appdata_full v, out Input o)
        {
            v.vertex = UnityFlipSprite(v.vertex, _Flip);

            #if defined(PIXELSNAP_ON)
            v.vertex = UnityPixelSnap (v.vertex);
            #endif

            UNITY_INITIALIZE_OUTPUT(Input, o);
            o.color = v.color * _Color * _RendererColor;
        }
        
        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = SampleSpriteTexture (IN.uv_MainTex) * IN.color;
            fixed4 wingsTex = tex2D(_WingsTex, (IN.screenPos.xy + _Time.x / 3) * 3);
            
            const float mask = saturate(step(c.r, 0.00001)
                                        + step(c.g + 0.01, 0.00001)
                                        + step(c.b, 0.00001));

            const float mask2 = saturate(c.r + c.g + c.b);

            // Compute colors "distance".
            float diffRed = abs(c.r - _ReplacedColor.r);
            float diffGreen = abs(c.g - _ReplacedColor.g);
            float diffBlue = abs(c.b - _ReplacedColor.b);
            float percentage = (diffRed + diffGreen + diffBlue) / 3;
            float mask3 = 1 - smoothstep(_SmoothStepA, _SmoothStepB, percentage);

            #if _DEBUGMASK_ON
                o.Albedo = mask3 * c.a;
            #else
                o.Albedo = ((c.rgb * (1 - mask3)) + (wingsTex * mask3)) * c.a;
            #endif
            
            o.Alpha = c.a;
        }
        
        ENDCG
    }

    Fallback "Transparent/VertexLit"
}