Shader "Black Hole/Base"
{
    Properties
    {
        _HoleWidth ("Hole Width", Range(0, 1)) = 0.5
        _HoleSmoothness ("Hole Smoothness", Range(0, 0.5)) = 0.1
        _DistortionPower ("Distortion Power", Range(0, 10)) = 1
        _FadeWidth ("Fade Width", Range(0, 1)) = 0.5
        _FadeSmoothness ("Fade Smoothness", Range(0, 0.5)) = 0.1
    }
    
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Transparent"
        }
        
        GrabPass
        {
            "_BackgroundTexture"
        }
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float compute_fresnel(const float3 normal, const float3 view_direction, const float power)
            {
                return pow(1 - saturate(dot(normalize(normal), normalize(view_direction))), power);
            }

            float4 remap(const float4 remapped_value, const float2 in_range, const float2 out_range)
            {
                return out_range.x + (remapped_value - in_range.x) * (out_range.y - out_range.x) / (in_range.y - in_range.x);
            }
            
            float3 remap(const float3 remapped_value, const float2 in_range, const float2 out_range)
            {
                return out_range.x + (remapped_value - in_range.x) * (out_range.y - out_range.x) / (in_range.y - in_range.x);
            }
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv              : TEXCOORD0;
                float4 vertex          : SV_POSITION;
                float3 normal          : NORMAL;
                float3 view_direction  : TEXCOORD1;
                float3 screen_position : TEXCOORD2;
                float4 grab_position   : TEXCOORD3;
            };

            sampler2D _BackgroundTexture;
            fixed _HoleWidth;
            fixed _HoleSmoothness;
            fixed _DistortionPower;
            fixed _FadeWidth;
            fixed _FadeSmoothness;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.view_direction = normalize(WorldSpaceViewDir(v.vertex));
                o.screen_position = o.vertex;
                o.grab_position = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float fresnel = compute_fresnel(i.normal, i.view_direction, 1);

                // Hole.
                const float hole_smoothstep_edge_a = 1 - _HoleWidth - _HoleSmoothness;
                const float hole_smoothstep_edge_b = 1 - _HoleWidth + _HoleSmoothness;
                float hole = 1 - smoothstep(hole_smoothstep_edge_a, hole_smoothstep_edge_b, 1 - fresnel);

                // Distortion.
                float distortion_fresnel = compute_fresnel(i.normal, i.view_direction, _DistortionPower);
                distortion_fresnel = pow(1 - distortion_fresnel, 6);
                float3 stretch = remap(i.screen_position, float2(0, 1), float2(1, -1));
                float4 distorted_uv = fixed4(i.screen_position + stretch * distortion_fresnel, 1);

                // Fade.
                const float fade_smoothstep_edge_a = _FadeWidth - _FadeSmoothness;
                const float fade_smoothstep_edge_b = _FadeWidth + _FadeSmoothness;
                float fade = 1 - smoothstep(fade_smoothstep_edge_a, fade_smoothstep_edge_b, 1 - fresnel);

                // Final color computation.
                half4 base_bg_color = tex2Dproj(_BackgroundTexture, i.grab_position);
                half4 distorted_bg_color = tex2Dproj(_BackgroundTexture, i.grab_position + distorted_uv);
                half4 bg_color = lerp(distorted_bg_color, base_bg_color, fade);
                
                return fixed4(bg_color * hole);
            }
            
            ENDCG
        }
    }
}
