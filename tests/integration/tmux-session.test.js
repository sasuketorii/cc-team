// tmuxセッション統合テスト
const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);

describe('tmuxセッション統合テスト', () => {
  test('tmuxがインストールされている', async () => {
    try {
      const { stdout } = await execPromise('which tmux');
      expect(stdout.trim()).toContain('tmux');
    } catch (error) {
      throw new Error('tmuxがインストールされていません');
    }
  });

  test('CCTeamセッションの作成と削除', async () => {
    // テスト用セッション名
    const testSession = 'ccteam-test-' + Date.now();
    
    try {
      // セッション作成
      await execPromise(`tmux new-session -d -s ${testSession}`);
      
      // セッションの存在確認
      const { stdout } = await execPromise(`tmux ls`);
      expect(stdout).toContain(testSession);
      
      // セッション削除
      await execPromise(`tmux kill-session -t ${testSession}`);
      
      // セッションが削除されたことを確認
      try {
        await execPromise(`tmux has-session -t ${testSession}`);
        fail('セッションが削除されていません');
      } catch (error) {
        // エラーが発生することが期待される（セッションが存在しない）
        expect(error).toBeTruthy();
      }
    } catch (error) {
      // クリーンアップ
      try {
        await execPromise(`tmux kill-session -t ${testSession}`);
      } catch (e) {
        // 既に削除されている場合は無視
      }
      throw error;
    }
  });

  test('複数ペインの作成', async () => {
    const testSession = 'ccteam-pane-test-' + Date.now();
    
    try {
      // セッション作成
      await execPromise(`tmux new-session -d -s ${testSession}`);
      
      // ペイン分割
      await execPromise(`tmux split-window -h -t ${testSession}:0`);
      await execPromise(`tmux split-window -v -t ${testSession}:0.0`);
      
      // ペイン数の確認
      const { stdout } = await execPromise(`tmux list-panes -t ${testSession} | wc -l`);
      expect(parseInt(stdout.trim())).toBe(3);
      
      // クリーンアップ
      await execPromise(`tmux kill-session -t ${testSession}`);
    } catch (error) {
      // クリーンアップ
      try {
        await execPromise(`tmux kill-session -t ${testSession}`);
      } catch (e) {
        // 既に削除されている場合は無視
      }
      throw error;
    }
  });
});