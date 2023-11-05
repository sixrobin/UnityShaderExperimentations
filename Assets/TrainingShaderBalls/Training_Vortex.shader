Shader "Training/Vortex"
{
    Properties
    {
        [Header(TWIRL (BASE))]
        [Space(5)]
        _MainTex ("Twirl Texture", 2D) = "white" {}
        _TwirlStrength ("Twirl Strength", Range(-20, 20)) = 1
        _RotationSpeed ("Rotation Speed", Range(-20, 20)) = 0
        [IntRange] _RadialMaskSharpness ("Radial Mask Sharpness", Range(1, 5)) = 1
        
        [Space(15)]
        
        [Header(TWIRL (COLOR))]
        [Space(5)]
        _TwirlColorA ("Twirl Color A", Color) = (1,1,1,1)
        _TwirlColorB ("Twirl Color B", Color) = (1,1,1,1)

        [Space(15)]
        
        [Header(CENTER)]
        [Space(5)]
        _CenterColor ("Center Color", Color) = (1,0,0,1)
        _CenterRadius ("Center Radius", Range(0.001, 1)) = 0.3
        _CenterSharpness ("Center Sharpness", Range(1, 5)) = 1
        
        [Space(15)]
        
        [Header(BLEND)]
        [Space(5)]
        [Enum(UnityEngine.Rendering.BlendMode)]
        _ScrBlend ("Source Blend", float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstBlend ("Destination Blend", float) = 1
    }
    
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Transparent"
        }
        
        Blend [_ScrBlend] [_DstBlend]
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
            };

            float2 twirl(float2 uv, float2 center, float strength, float2 offset, float rotation)
            {
                float2 delta = uv - center;
                float angle = strength * length(delta) + rotation;
                float x = cos(angle) * delta.x - sin(angle) * delta.y;
                float y = sin(angle) * delta.x + cos(angle) * delta.y;
                return float2(x + center.x + offset.x, y + center.y + offset.y);
            }
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _TwirlStrength;
            float _RotationSpeed;
            float _RadialMaskSharpness;

            float4 _TwirlColorA;
            float4 _TwirlColorB;

            float4 _CenterColor;
            float _CenterRadius;
            float _CenterSharpness;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = v.normal;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Uv center.
                float2 uv_centered = i.uv * 2 - 1;
                float radial_distance = length(uv_centered);

                // Center.
                float center_mask = saturate(1 - pow(radial_distance / _CenterRadius, _CenterSharpness));
                float4 col_center = _CenterColor * center_mask;
                
                // Twirl.
                float2 uv_twirl = twirl(i.uv, 0.5, _TwirlStrength, 0, _Time.y * _RotationSpeed);
                fixed4 tex_twirl = tex2D(_MainTex, uv_twirl);
                tex_twirl = saturate(tex_twirl * (1 - pow(radial_distance, _RadialMaskSharpness)));
                fixed4 col_twirl = saturate(pow(tex_twirl, 2)) * (lerp(_TwirlColorA, _TwirlColorB, radial_distance)) * (1 - center_mask);
                
                // Final color.
                return col_twirl + col_center;
            }
            
            ENDCG
        }
    }
}