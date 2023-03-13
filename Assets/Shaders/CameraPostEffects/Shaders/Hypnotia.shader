Shader "MyShaders/Hypnotia" {

	Properties
	{
		_MainTex("-", 2D) = "yellow" {}
		_segment("Divisor Value", float) = 6
		_strength("Movement Strength", float) = 2.5
		_speed("Time Controller", float) = 0.5
	}
		
	CGINCLUDE
	#include "UnityCG.cginc"

	sampler2D _MainTex;
	float _segment;
	float _strength;
	float _speed;

	half4 frag(v2f_img i) : SV_Target
	{
		float2 screen = (float2)0;
		screen = i.uv - 0.5;

		float phi, rad = (float)0;
		phi = atan2(screen.y, screen.x);
		rad = sqrt(dot(screen, screen));

		phi = phi - _segment * floor(phi / _segment);
		phi = min(phi, _segment - phi);
		phi += _strength * _SinTime * _speed;

		float2 uv = (float2)0;
		uv = float2(cos(phi), sin(phi)) * rad + 0.5;
		uv = max(min(uv, 2.0 - uv), -uv);

		float4 sum = (float4)0;
		sum = -9 * tex2D(_MainTex, 0);

		float2 offsets[9] =
		{
			float2(-1, -1),
			float2(-1, 0),
			float2(-1, 1),
			float2(0, -1),
			float2(0, 0),
			float2(0, 1),
			float2(1, -1),
			float2(1, 0),
			float2(1, 1)
		};

		for (int j = 0; j < 9; j++)
			sum += tex2D(_MainTex, uv + _strength/5 * _SinTime * _speed * offsets[j]);

		sum.rgb *= dot(sum.xyz * sum.rgb, 0.5);
		sum.rgb += pow(sum.rgb, 0.5);

		sum *= 7;
		sum = floor(sum);
		sum /= 7;

#ifdef INVERT
		sum = 1 - sum;
#endif
		return fixed4(sum);
	}

	ENDCG
		
	SubShader 
	{
		Pass 
		{
			ZTest Always 
			Cull Off 
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma shader_feature INVERT
			ENDCG
		}
	}
	Fallback off
}
