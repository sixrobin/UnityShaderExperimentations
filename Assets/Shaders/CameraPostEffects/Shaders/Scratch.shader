Shader "MyShaders/Scratch"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_scalar("Scalar Texture", 2D) = "white" {}
		_count("Sprite Block Count", float) = 0
		_ratio("Multiplicator", int) = 0
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	sampler2D _MainTex;
	sampler2D _scalar;
	float2 _count;
	int _ratio;

	fixed4 frag(v2f_img i) : SV_Target
	{				
		float2 pos = floor(i.uv * _count);
		float2 center = pos * 1/_count + 1/_count * 0.5;
				
		float4 sum = tex2D(_MainTex, center);
		float gray = dot(sum.rgb, float3(0.31, 0.59, 0.11));
		float dx = floor(gray * _ratio);

		float2 scl = i.uv;
		scl -= pos * 1/_count;
		scl.x /= _ratio;
		scl *= _count;
		scl.x += 1.0 / _ratio * dx;

#ifdef COLORED
		sum *= tex2D(_scalar, scl);
#else
		sum = tex2D(_scalar, scl);
#endif
		return fixed4(sum);
	}

	ENDCG

	Subshader 
	{
		Pass
		{
			ZTest Always
			Cull Off
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma shader_feature COLORED
			ENDCG
		}
	}
	Fallback off
}