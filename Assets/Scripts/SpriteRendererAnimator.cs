namespace RSLib
{
    using UnityEngine;
    #if ODIN_INSPECTOR
    using Sirenix.OdinInspector;
    #endif

    /// <summary>
    /// Plays a simple animation on a SpriteRenderer's sprite, with a constant frame rate and sprites sequence.
    /// Can be used to loop a simple animation without creating an Animation and AnimatorController.
    /// </summary>
    public class SpriteRendererAnimator : MonoBehaviour
    {
        #if ODIN_INSPECTOR
        [FoldoutGroup("Refs")]
        #endif
        [SerializeField] private SpriteRenderer _spriteRenderer = null;
        
        #if ODIN_INSPECTOR
        [FoldoutGroup("Data")]
        #endif
        [SerializeField] private Sprite[] _sprites = null;
        
        #if ODIN_INSPECTOR
        [FoldoutGroup("Data")]
        #endif
        [SerializeField, Min(1)] private int _frameRate = 12;
        
        #if ODIN_INSPECTOR
        [FoldoutGroup("Data")]
        #endif
        [SerializeField] private bool _randomizeStartSprite = false;

        #if ODIN_INSPECTOR
        [FoldoutGroup("Data")]
        #endif
        public bool Paused;

        private int _currentSpriteIndex;
        private float _timer;

        private void Start()
        {
            if (_randomizeStartSprite)
                _currentSpriteIndex = Random.Range(0, _sprites.Length);

            if (_sprites.Length > 0)
                _spriteRenderer.sprite = _sprites[_currentSpriteIndex];
        }

        private void Update()
        {
            if (Paused)
                return;

            _timer += Time.deltaTime;
            if (_timer < 1f / _frameRate)
                return;

            if (_sprites.Length > 0)
            {
                _currentSpriteIndex = ++_currentSpriteIndex % _sprites.Length;
                _spriteRenderer.sprite = _sprites[_currentSpriteIndex];
                _timer = 0f;
            }
        }

        private void Reset()
        {
            _spriteRenderer = _spriteRenderer ?? GetComponent<SpriteRenderer>();
        }
    }
}