Shader "MyShader/c6/specularVertex"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
		_Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
		_Gloss("Gloss", Range(8.0, 256.0)) = 32.0
	}

	SubShader
	{
		Pass
		{
			Tags{"LightMode"="ForwardBase"}
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 color : COLOR;
			};

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			v2f vert(in appdata_base i)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

				fixed3 worldNormal = normalize(mul(i.normal, (float3x3)_World2Object));
				fixed3 worldLight = normalize( _WorldSpaceLightPos0.xyz );
//				float diff = saturate( dot(worldNormal, worldLight) );
				float diff = dot(worldNormal, worldLight) * 0.5 + 0.5;
				fixed3 diffuse = _Diffuse.rgb * diff * _LightColor0.rgb;

				float3 fragWorldPos = mul(_Object2World, i.vertex).xyz;
				fixed3 worldView = normalize(fragWorldPos - _WorldSpaceCameraPos);
				fixed3 reflectDir = normalize(reflect(-worldLight, worldNormal));
				float spec = pow(saturate(dot(reflectDir, -worldView)), _Gloss);
				fixed3 specular = _Specular * spec * _LightColor0.rgb;
				o.color = ambient + diffuse + specular;

				return o;
			}

			fixed4 frag(in v2f i):SV_Target
			{
				fixed4 fragColor = fixed4(i.color, 1.0);
				return fragColor;
			}

			ENDCG
		}
	}

	Fallback "Diffuse"

}