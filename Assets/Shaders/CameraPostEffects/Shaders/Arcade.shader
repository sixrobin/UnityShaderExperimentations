// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/Arcade" {

	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_contour("Contour Size", float) = 1
		_vignette("Vignette Strength", float) = 0.75
		_aberration("Chromatic Aberration", float) = 0.5
		_lens("Lens Strength", float) = 0.25
		_cubic("Screen Adjustment", float) = 0.1
		_intensity("FX Intensity", float) = 0.25
		_speed("Time Controller", float) = 1
	}
	
	CGINCLUDE
	#include "UnityCG.cginc"

	sampler2D _MainTex;
	float _contour;
	float _vignette;
	float _aberration;
	float _lens;
	float _cubic;
	float _intensity;
	float _speed;

	struct v2f 
	{
		float4 pos : POSITION;
		float2 uv : TEXCOORD0;
	};

	v2f vert(appdata_img v) 
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord.xy;
		return o;
	}

	inline float2 curve(float2 uv)
	{
		uv = (uv - 0.5) * 2.0;
		uv *= 1.1;
		uv.x *= 1.0 + pow((abs(uv.y) * _contour / 5), 2.0);
		uv.y *= 1.0 + pow((abs(uv.x) * _contour / 4), 2.0);
		uv = (uv / 2.0) + 0.5;
		uv = uv * 0.92 + 0.039;
		return uv;
	}

	float4 frag(v2f i) : SV_Target
	{
		float2 uv = i.uv.xy;
		uv = curve(uv);

		float4 sum = (float4)0;
		sum = tex2D(_MainTex, float2(uv.x, uv.y));

		float dist, factor = (float)0;
		dist = pow((i.uv.x - 0.5), 2) + pow((i.uv.y - 0.5), 2);
		factor = 1 + dist * (_lens + sqrt(_cubic/20) * sqrt(dist * 1000));

		float distX, distY = (float)0;
		distX = factor * (i.uv.x - 0.5) + 0.5;
		distY = factor * (i.uv.y - 0.5) + 0.5;

		sum += tex2D(_MainTex , float2(distX, distY));

		float2 coords = i.uv;
		coords = (coords - 0.5) * 2.0;
		float pi = 3.14;

		float2 offset = (float2)0;
		offset.x = coords.x * sqrt(_aberration * 0.00001) * (factor * pi);
		offset.y = coords.y * sqrt(_aberration * 0.00001) * (factor * pi);

		float red, green, blue = (float)0;
		red = tex2D(_MainTex, uv + offset * 3 * _aberration).r;
		green = tex2D(_MainTex, uv + offset * 5 * _aberration).g;
		blue = tex2D(_MainTex, uv + offset * 8 * _aberration).b;

		sum += (float4(red, 0, 0, 1) + float4(0, green, 0, 1) + float4(0, 0, blue, 1));
		sum += (float4(red, green, blue, 1) + float4(red, green, blue, 1) + float4(red, green, blue, 1));
		sum /= 6;

		sum.r += cos(uv.y * 999 + _Time.z * _speed * 10) * _intensity;
		sum.g += cos(uv.y * 888 + _Time.z * _speed * 10) * _intensity/2;
		sum.b += cos(uv.y * 777 + _Time.z * _speed * 10) * _intensity/3;

		float3 col = (float3)0;
		col.rgb += sum.xyz;

		col.r += 0.033 * sum.x;
		col.g += 0.033 * sum.y;
		col.b += 0.033 * sum.z;
		col = clamp(col * 0.6 + 0.4 * col * col, 0.08, 1.0);

		float vignette = (float)0;
		vignette = (10.0 * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y));
		col *= pow(vignette, _vignette / 2);

		if (uv.x < 0.0 || uv.x > 1.0)
			col = 0.025;
		if (uv.y < 0.0 || uv.y > 1.0)
			col = 0.025;

		return fixed4(sum * col, 1.0);
	}

	ENDCG
	
	SubShader 
	{
		Pass
		{
			ZTest Always
			Cull Off
			ZWrite Off
			Fog{ Mode off }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 3.0
			ENDCG
		}
	}
}
