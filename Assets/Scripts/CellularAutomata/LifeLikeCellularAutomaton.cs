using UnityEngine;

public class LifeLikeCellularAutomaton : CellularAutomaton
{
    [SerializeField]
    private string _rules;
    [SerializeField, Range(0f, 1f)]
    private float _randomStep = 0.5f;

    protected override void Init()
    {
        base.Init();

        Vector2Int rules = this.ParseRules();
        this._computeShader.SetInts("Rules", rules.x, rules.y);

        this._computeShader.SetFloat("InitRandomStep", this._randomStep);
        this._computeShader.SetTexture(0, "Result", this._gridBuffer);
        this._computeShader.Dispatch(0, this.Resolution / 8, this.Resolution / 8, 1);

        this._computeShader.SetTexture(2, "Result", this._grid);
        this._computeShader.SetTexture(2, "GridBuffer", this._gridBuffer);
        this._computeShader.Dispatch(2, this.Resolution / 8, this.Resolution / 8, 1);
    }

    protected override void Next()
    {
        base.Next();
        
        this._computeShader.SetTexture(1, "Result", this._grid);
        this._computeShader.SetTexture(1, "GridBuffer", this._gridBuffer);
        this._computeShader.Dispatch(1, this.Resolution / 8, this.Resolution / 8, 1);
        
        this.ApplyTextureBuffer();
    }

    private Vector2Int ParseRules()
    {
        Vector2Int parsedRules = Vector2Int.zero;
        string rules = this._rules;
        rules = rules.ToUpper();

        try
        {
            string[] rulesSplit = rules.Split('/');
            string birthRules = rulesSplit[0];
            string surviveRules = rulesSplit[1];

            birthRules = birthRules.Remove(0, 1);
            surviveRules = surviveRules.Remove(0, 1);

            foreach (char birthRule in birthRules)
            {
                int neighboursCount = int.Parse($"{birthRule}");
                neighboursCount = (int)Mathf.Pow(2, neighboursCount);
                parsedRules.x += neighboursCount;
            }
            
            foreach (char surviveRule in surviveRules)
            {
                int neighboursCount = int.Parse($"{surviveRule}");
                neighboursCount = (int)Mathf.Pow(2, neighboursCount);
                parsedRules.y += neighboursCount;
            }
        }
        catch (System.Exception e)
        {
            Debug.LogError($"Could not parse rules {rules}! Make sure rules format is B[x]/S[x].");
            parsedRules = Vector2Int.zero;
        }

        return parsedRules;
    }
}
