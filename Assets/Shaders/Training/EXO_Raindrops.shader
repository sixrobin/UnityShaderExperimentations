Shader "Custom/EXO_Raindrops"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo", 2D) = "white" {}
        [Normal] _Normal ("Normal", 2D) = "bump" {}
        _Glossiness ("Smoothness", Range(0, 1)) = 0.5
        _Metallic ("Metallic", Range(0, 1)) = 0
        
        [Header(RAINDROPS)]
        [Space(5)]
        _Raindrops ("Raindrops", 2D) = "black" {}
        _AnimatedRaindropsSpeed ("Animated Raindrops Speed", Float) = 1
    }
    
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        
        LOD 200

        CGPROGRAM
        
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_Raindrops;
        };

        sampler2D _MainTex;
        sampler2D _Normal;
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        sampler2D _Raindrops;
        float _AnimatedRaindropsSpeed;

        fixed3 UnpackNormalRGToRGB(fixed4 packedNormal)
        {
            fixed3 normal;
            normal.xy = packedNormal.xy * 2 - 1;
            normal.z = sqrt(1 - saturate(dot(normal.xy, normal.xy)));
            return normal;
        }
        
        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 color = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            fixed3 mainTexNormal = UnpackNormal(tex2D(_Normal, IN.uv_MainTex));

            fixed4 raindrops = tex2D(_Raindrops, IN.uv_Raindrops);

            fixed3 raindropsNormal = UnpackNormalRGToRGB(raindrops);
            fixed raindropTemporalOffsetMask = raindrops.b;
            fixed raindropAnimatedStaticMask = raindrops.a;

            fixed raindropNormalIntensity = 1 - (_Time.y * _AnimatedRaindropsSpeed + raindropTemporalOffsetMask) % 1;
            
            o.Albedo = color.rgb;
            o.Alpha = color.a;
            
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Normal = lerp(mainTexNormal, raindropsNormal, raindropNormalIntensity);
        }
        
        ENDCG
    }
    
    FallBack "Diffuse"
}
