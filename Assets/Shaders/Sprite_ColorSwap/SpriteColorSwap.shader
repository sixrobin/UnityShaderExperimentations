Shader "Sprites/Color Swap"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        [PerRendererData] _ColorSwapMask ("Color Swap Mask", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        _ColorSwapShift ("Hue Shift", Range(0, 6.283)) = 0 // 6.283 = TAU
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
        
        #pragma surface surf Lambert vertex:vert nofog nolightmap nodynlightmap keepalpha noinstancing
        #pragma multi_compile_local _ PIXELSNAP_ON
        #pragma multi_compile _ ETC1_EXTERNAL_ALPHA
        #include "UnitySprites.cginc"

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_ColorSwapMask;
            fixed4 color;
        };
        
        sampler2D _ColorSwapMask;
        fixed4 _ColorSwapMask_SV;
        half _ColorSwapShift;
        
        float3 ColorCorrection(float3 color)
        {
            const float3x3 yiq_to_rgb = { +1.0000, +0.9563, +0.6210,
                                          +1.0000, -0.2721, -0.6474,
                                          +1.0000, -1.1070, +1.7046 };

            const float3x3 rgb_to_yiq = { +0.2990, +0.5870, +0.1140,
                                          +0.5957, -0.2745, -0.3213,
                                          +0.2115, -0.5226, +0.3112 };

            float3 yiq = mul(rgb_to_yiq, color);
            
            const float hue = atan2(yiq.z, yiq.y) + _ColorSwapShift;
            const float chroma = length(float2(yiq.y, yiq.z));

            float y = yiq.x;
            float i = chroma * cos(hue);
            float q = chroma * sin(hue);

            const float3 yiq_shift = float3(y, i, q);
            float3 rgb = mul(yiq_to_rgb, yiq_shift);
            
            return rgb;
        }
        
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
            fixed4 main_tex = SampleSpriteTexture(IN.uv_MainTex) * IN.color;

            fixed color_swap_mask = tex2D(_ColorSwapMask, IN.uv_MainTex).r;
            fixed3 swapped_color = ColorCorrection(main_tex.rgb);
            
            fixed4 color = lerp(main_tex, fixed4(saturate(swapped_color).rgb, 1), color_swap_mask.r);
            
            o.Albedo = color * main_tex.a;
            o.Alpha = main_tex.a;
        }
        
        ENDCG
    }

    Fallback "Transparent/VertexLit"
}
