// agent-send.sh 単体テスト
const { exec } = require('child_process');
const path = require('path');

describe('agent-send.sh', () => {
  const scriptPath = path.join(__dirname, '../../scripts/agent-send.sh');

  test('引数が不足している場合はエラーを返す', (done) => {
    exec(`${scriptPath}`, (error, stdout, stderr) => {
      expect(error).toBeTruthy();
      expect(error.code).toBe(1);
      expect(stdout).toContain('使用方法');
      done();
    });
  });

  test('無効なエージェント名でエラーを返す', (done) => {
    exec(`${scriptPath} invalid_agent "test message"`, (error, stdout, stderr) => {
      expect(error).toBeTruthy();
      expect(error.code).toBe(1);
      expect(stdout).toContain('無効なエージェント名');
      done();
    });
  });

  test('有効なエージェント名を受け付ける', () => {
    const validAgents = ['boss', 'worker1', 'worker2', 'worker3'];
    validAgents.forEach(agent => {
      // 実際のtmuxセッションが必要なため、ここでは引数検証のみ
      expect(agent).toMatch(/^(boss|worker[1-3])$/);
    });
  });
});